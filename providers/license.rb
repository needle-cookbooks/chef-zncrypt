require 'digest/sha1'

action :activate do

  unless get_zncrypt_license and get_zncrypt_activation

    # construct a hash where we store the license data
    @license_data = {
      'allocated_to' => node['hostname'],
      'passphrase' => @new_resource.passphrase
    }

    unless @new_resource.salt.empty?
      # the salt is optional (also referred to as second passphrase)
      @license_data.merge!({ 'salt' => @new_resource.salt })
    end

    unless @new_resource.license.empty? and @new_resource.activation_code.empty?
      # use license and activation code from LWRP, if they have been passed in
      @license_data.merge!({
        'license' => @new_resource.license,
        'activation_code' => @new_resource.activation_code
      })
    else
      # otherwise, try looking in the data bag for an available license
      ensure_data_bag(@new_resource.data_bag)

      begin
        @available_licenses = search(@new_resource.data_bag, "id:license_index").first['licenses']
      rescue => e
        @available_licenses = { }
        Chef::Log.warn("zncrypt: error loading license index from #{@new_resource.data_bag} data bag")
      end

      unless @available_licenses.empty?
        Chef::Log.debug("zncrypt: found #{@available_licenses.count} available licenses \n" + @available_licenses.inspect)
        # select available licence from the index
        @selected_license = @available_licenses.shift
        @license_data.merge!({
          'license' => @selected_license[0],
          'activation_code' => @selected_license[1]
        })
      else
        # we haven't been passed a license/activation code, and 
        # there are no available licenses in the bag, so we'll make one.
        # the default license will auto reset every hour if your first registration fails, 
        # try again in an hour or contact sales@gazzang.com
        @license_data.merge!({ 
         'license' => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
         'activation_code' => "123412341234"
        })
      end
    end

    # now we'll generate a unique ID for the license using a sha1 hash
    @license_data.merge!({'id' => Digest::SHA1.hexdigest(@license_data['license']+@new_resource.name+Time.new.usec.to_s)})

    # by this point we should have generated a license hash from:
    # a) values passed by the LWRP
    # b) values retrieved from the license index in the data bag
    # c) the dummy license provided by gazzang's own cookbook
    Chef::Log.info("zncrypt license: " + @license_data.inspect)
    Chef::Log.debug("zncrypt available licenses: " + @available_licenses.inspect)

    # now it is time to save our work
    # generate a new license index, now minus the license we just used up.
    @license_index = { 'id' => 'license_index', 'licenses' => @available_licenses }

    # first, we save both the updated license_index and new license data to the data bag
    [ @license_index, @license_data ].each do |lic|
      begin
        Chef::Log.debug("attempting to save #{lic['id']} to data bag #{@new_resource.data_bag}")
        databag_item = Chef::DataBagItem.new
        databag_item.data_bag(@new_resource.data_bag)
        databag_item.raw_data = lic
        databag_item.save
      rescue => e
        Chef::Log.fatal(e)
        raise
      end
    end

    # save the license and activation code to the node data, just for good measure,
    # but only after we've been notified by the "activate ezncrypt" script resource
    ruby_block "save license for #{node['hostname']} to node object" do
      block do
        node['zncrypt']['license'] = @license_data['license']
        node['zncrypt']['activation_code'] = @license_data['activation_code']
        node.save
        @new_resource.updated_by_last_action(true)
      end
      action :nothing
    end

    activate_args="--activate --license=#{@license_data['license']} --activation-code=#{@license_data['activation_code']} --passphrase=#{@license_data['passphrase']}"

    activate_args + " --passphrase2=#{@license_data['salt']}" if @license_data['salt']

    directory "/var/log/ezncrypt"

    script "activate zncrypt for #{node['hostname']}" do
      interpreter "bash"
      user "root"
      code <<-EOH
      ezncrypt-activate #{activate_args}
      EOH
      not_if { node['zncrypt']['license'] == @license_data['license'] }
      notifies :create, "ruby_block['save_license']", :immediately
    end

  else
    Chef::Log.info('zncrypt is already actviated, skipping activation process.')
  end

end
