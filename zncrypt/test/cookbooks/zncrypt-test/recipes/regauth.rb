#
# Cookbook Name:: zncrypt-test
# Recipe:: regauth
#
# Copyright 2013, Needle Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

z_storage = node['zncrypt_test']['storage']
z_mount = node['zncrypt_test']['mount']
z_passphrase = node['zncrypt_test']['passphrase']
z_salt = node['zncrypt_test']['salt']

package "haveged"

include_recipe "zncrypt::zncrypt"

zncrypt_license node['fqdn'] do
  admin_email node['zncrypt_test']['admin_email']
  passphrase z_passphrase
  salt z_salt
  org node['zncrypt_test']['org_name']
  auth node['zncrypt_test']['org_auth']
  regmode :regauth
  action :activate
end

[ z_mount, z_storage ].each do |dir|
  directory dir do
    recursive true
  end
end

zncrypt_storage z_storage do
  mount_point z_mount
  passphrase z_passphrase
  salt z_salt
end

include_recipe 'zncrypt-test::_acls'

directory '/data/secrets' do
  recursive true
end

file '/data/secrets/secret.txt' do
  content 'trustno1'
end

zncrypt_move '/data/secrets' do
  mount_point z_mount
  group "trusted"
  passphrase z_passphrase
  salt z_salt
  action :encrypt
end
