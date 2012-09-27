require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

ZNCRYPT_LICENSE_FILE = '/etc/ezncrypt/license/standard-license.key'

def which(*args)
  # shamelessly lifted from http://stackoverflow.com/questions/6624348/ruby-equivalent-to-which
  ret = []
  args.each{ |bin|
    possibles = ENV["PATH"].split( File::PATH_SEPARATOR )
    possibles.map {|p| File.join( p, bin ) }.find {|p|  ret.push p if File.executable?(p) } 
  }
  ret
end

def mounted?(path)
  case Chef::Mixin::ShellOut.shell_out("grep #{path} /proc/mounts").exitstatus
  when 1
    false
  when 0
    true
  end
end

def zncrypt_licensed?
  unless ::File.exists?(ZNCRYPT_LICENSE_FILE)
    return false
  else
    return true
  end
end

def get_zncrypt_activation
  if zncrypt_licensed?
    lines = IO.readlines(ZNCRYPT_LICENSE_FILE)
    return lines[1].chop
  else
    return false
  end
end

def get_zncrypt_license
  if zncrypt_licensed?
    lines = IO.readlines(ZNCRYPT_LICENSE_FILE)
    return lines[0].chop
  else
    return false
  end
end

def load_license(bag,hostname)
  begin
    licenses = search(bag, "allocated_to:#{hostname}")
    if licenses.count == 1
      Chef::Log.debug("zncrypt acl: successfully loaded license: \n" + licenses.first.raw_data.inspect )
      return licenses.first.raw_data
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

def ensure_data_bag(bag)
  begin
    data_bag(bag)
  rescue
    new_bag = Chef::DataBag.new
    new_bag.name(bag)
    new_bag.save
  end
end
