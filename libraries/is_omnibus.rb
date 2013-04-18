# cargoculted from Chef's rubygems package provider
def is_omnibus?
  if RbConfig::CONFIG['bindir'] =~ %r!/opt/(opscode|chef)/embedded/bin!
    Chef::Log.debug("zncrypt detected omnibus installation in #{RbConfig::CONFIG['bindir']}")
    # Omnibus installs to a static path because of linking on unix, find it.
    true
  elsif RbConfig::CONFIG['bindir'].sub(/^[\w]:/, '')  == "/opscode/chef/embedded/bin"
    Chef::Log.debug("zncrypt detected omnibus installation in #{RbConfig::CONFIG['bindir']}")
    # windows, with the drive letter removed
    true
  else
    false
  end
end
