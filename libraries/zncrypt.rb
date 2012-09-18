ZNCRYPT_LICENSE_FILE = '/etc/ezncrypt/license/standard-license.key'

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