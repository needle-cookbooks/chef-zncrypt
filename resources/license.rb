include Opscode::OpenSSL::Password

actions :activate

attribute :license,         :kind_of => String, :default => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
attribute :activation_code  :kind_of => String, :default => "123412341234"
attribute :passphrase       :kind_of => String, :default => secure_password
attribute :salt             :kind_of => [String,FalseClass], :default => false
attribute :available        :kind_of => [TrueClass,FalseClass], :default => true
attribute :data_bag         :kind_of => String, :default => 'zncrypt_licence_pool'