::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

rand_passphrase = secure_password
rand_salt = secure_password

zncrypt_license node['hostname'] do
  passphrase rand_passphrase
  salt rand_salt
  action :activate
end