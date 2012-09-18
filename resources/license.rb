actions :activate

attribute :license,         :kind_of => String, :default => String.new
attribute :activation_code, :kind_of => String, :default => String.new
attribute :passphrase,      :kind_of => String, :required => true
attribute :salt,            :kind_of => String, :default => String.new
attribute :available,       :kind_of => [TrueClass,FalseClass], :default => true
attribute :data_bag,        :kind_of => String, :default => 'zncrypt_license_pool'