require 'digest/sha1'

def initialize(*args)
  super
  @action = :activate
end

def load_current_resource
  @current_resource = Chef::Resource::ZncryptLicense.new(@@new_resource.name)
  @current_resource.license = zncrypt_license
  @current_resource.activation_code = zncrypt_activation
  @current_resource.passphrase = false

  @current_resource
end

action :activate do

  # construct a hash where we store the license data
  @license_data = {
    :allocated_to => node['name'],
    :passphrase => @new_resource.passphrase
  }

  if @new_resource.salt
    # the salt is optional (also referred to as second passphrase)
    @license_data.merge!({ :salt => @new_resource.salt })
  end

  if @new_resource.license and @new_resource.activation_code
    # use license and activation code from LWRP, if they have been passed in
    @license_data.merge!({
      :license => @new_resource.license,
      :activation_code => @new_resource.activation_code
    })
  else
    # otherwise, try looking in the data bag for an available license
    ensure_data_bag(@new_resource.data_bag)
    @available_licenses = search(@new_resource.data_bag, "id:license_index")['licenses']

    unless @available_licenses.empty?
      # select available licence from the index
      items = @available_licenses.values
      @selected_license = licenses[rand(items.length)]

      @license_data.merge!({
        :license => @selected_license.keys[0],
        :activation_code => @selected_license.values[0]
      })

      # remove the license we've allocated to this node from the index
      @available_licenses.delete(@license_data[:license])
    else
      # we haven't been passed a license/activation code, and 
      # there are no available licenses in the bag, so we'll make one.
      # the default license will auto reset every hour if your first registration fails, 
      # try again in an hour or contact sales@gazzang.com
      @license_data.merge!({ 
       :license => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
       :activation_code => "123412341234"
      })
    end
  end

  # now we'll generate a unique ID for the license using a sha1 hash
  @license_data.merge!({:id => Digest::SHA1.hexdigest(@license_data[:license]+node['name'])})

  # by this point we should have generated a license hash from:
  # a) values passed by the LWRP
  # b) values retrieved from the license index in the data bag
  # c) the dummy license provided by gazzang's own cookbook
  Chef::Log.debug("zncrypt_license: " + @license_data.inspect)
  Chef::Log.debug("available licenses: " + @available_licenses.inspect)

  # now we must save our work

  @license_index = { :id => "license_index", :licenses => @available_licenses }

  # first, we save both the updated license_index and new license data to the data bag
  [ @license_index, @license_data ].each do |lic|
    begin
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
  ruby_block "save license for #{node['name']} to node object" do
    block do
      node['zncrypt']['license'] = @license_data[:license]
      node['zncrypt']['activation_code'] = @license_data[:activation_code]
      node.save
      @new_resource.updated_by_last_action(true)
    end
    action :nothing
  end

  activate_args="--activate --license=#{@license_data[:license]} --activation-code=#{@license_data[:activation_code]} --passphrase=#{@license_data[:passphrase]}"

  activate_args + " --passphrase2=#{@license_data[:salt]}" if @license_data[:salt]

  directory "/var/log/ezncrypt"

  script "activate zNcrypt for #{node['name']}" do
    interpreter "bash"
    user "root"
    code <<-EOH
    ezncrypt-activate #{activate_args}
    EOH
    not_if { node['zncrypt']['license'] == @license_data[:license] }
    notifies :create, "ruby_block['save_license']", :immediately
  end

end
  