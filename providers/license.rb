def initialize(*args)
  super
  @action = :activate
end

action :activate do

  ensure_data_bag(new_resource.data_bag)
  licenses = search(new_resource.data_bag, "available:true")

  unless licenses.empty?
    # select an available licence from the bag
    license = licenses.sample.raw_data
    license['passphrase'] = new_resource.passphrase
    license['available'] = false
    license['allocated_to'] = node['name']
    license['salt'] = new_resource.salt if new_resource.salt
  else
    # if there are no available licenses in the bag, make one
    # the default license will auto reset every hour
    # if your first registration fails try again in an hour or contact sales@gazzang.com
    license = { 
     "id" => new_resource.license,
     "activation_code" => new_resource.activation_code,
     "passphrase" => new_resource.passphrase,
     "available" => false,
     "allocated_to" => node['name']
    }

    # the salt is optional (also referred to as second passphrase)
    if new_resource.salt
      license['salt'] = new_resource.salt
    end
  end

  begin
    databag_item = Chef::DataBagItem.new
    databag_item.data_bag(new_resource.data_bag)
    databag_item.raw_data = license
    databag_item.save
  rescue => e
    Chef::Log.fatal(e)
    raise
  end

  activate_args="--activate --license=#{license['id']} --activation-code=#{license['activation_code']} --passphrase=#{license['passphrase']}"

  activate_args + " --passphrase2=#{license['salt']}" if license['salt']

  directory "/var/log/ezncrypt"

  script "activate zNcrypt" do
    interpreter "bash"
    user "root"
    code <<-EOH
    ezncrypt-activate #{activate_args}
    EOH
    not_if {::File.exists?('/etc/ezncrypt/license/standard-license.key')}
  end

end
  