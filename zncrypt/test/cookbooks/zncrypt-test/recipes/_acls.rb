z_passphrase = node['zncrypt_test']['passphrase']
z_salt = node['zncrypt_test']['salt']

# allow chef
omnibus = Gem.bindir =~ %r{/opt/(opscode|chef)/}

chef_exe = case Chef::Config[:solo]
when true
  omnibus ? '/opt/chef/bin/chef-solo' : which('chef-solo').first
when false
  omnibus ? '/opt/chef/bin/chef-client' : which('chef-client').first
end

ruby_exe = omnibus ? ::File.join(Gem.bindir, 'ruby') : node['languages']['ruby']['ruby_bin']

# allow chef
zncrypt_acl ruby_exe do
  group "trusted"
  path "data/secrets/*"
  shell '/bin/bash'
  permission "ALLOW"
  children chef_exe
  passphrase z_passphrase
  salt z_salt
end

# allow ls
zncrypt_acl '/bin/ls' do
  group "trusted"
  path "*"
  permission "ALLOW"
  shell "/bin/bash"
  passphrase z_passphrase
  salt z_salt
end
