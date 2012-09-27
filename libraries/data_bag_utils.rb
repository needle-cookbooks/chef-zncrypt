def ensure_data_bag(bag)
  begin
    data_bag(bag)
  rescue
    new_bag = Chef::DataBag.new
    new_bag.name(bag)
    new_bag.save
  end
end

def load_license(bag,hostname)
  begin
    licenses = search(bag, "allocated_to:#{hostname}")
    if licenses.count = 1
      Chef::Log.debug("zncrypt acl: successfully loaded license: \n" + licenses.first )
      return licenses.first
    else
      Chef::Log.fatal("zncrypt acl: found multiple licenses for node #{hostname} in the #{bag} data bag, cannot proceed.")
      raise
    end
  rescue
    Chef::Log.fatal("zncrypt acl: failed to locate a license for node #{hostname} in the #{bag} data bag, cannot proceed.")
    raise
  end
end

def load_passphrase(bag)
  load_license(bag)['passphrase']
end

def load_salt(bag)
  load_license(bag)['salt']
end