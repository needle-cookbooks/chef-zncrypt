::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

zncrypt_license node['hostname'] do
  passphrase secure_password
  salt secure_password
  action :activate
end