ZNCRYPT_LICENSE_FILE = '/etc/ezncrypt/license/standard-license.key'

def zncrypt_licensed?
  unless ::File.exists?(ZNCRYPT_LICENSE_FILE)
    return false
  else
    return true
  end
end

def zncrypt_activation
  if zncrypt_licensed?
    lines = IO.readlines(ZNCRYPT_LICENSE_FILE)
    return lines[1].chop
  end
end

def zncrypt_license
  if zncrypt_licensed?
    lines = IO.readlines(ZNCRYPT_LICENSE_FILE)
    return lines[0].chop
  end
end