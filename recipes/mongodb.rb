#
# Author:: Eddie Garcia (<eddie.garcia@gazzang.com>)
# Cookbook Name:: zncrypt
# Recipe:: mongodb
#
# Copyright 2012, Gazzang, Inc.
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

case node['platform_family']
when "rhel","fedora"
 data_dir="/var/lib/mongo"
 service_name="mongod"
when "debian"
 data_dir="/var/lib/mongodb"
 service_name="mongodb"
end

# let the mongodb cookbook do our heavy lifting
include_recipe "mongodb::default"

# Mongo is installed, we proceed to set up the encryption
# the path here is hardcoded, if it does not match yours edit here
acl_rule1="/usr/bin/mongod"
acl_rule2="/bin/mkdir"

# before anything we stop mongodb
# create the ACLs
passphrase=data_bag_item('license_pool', 'license1')['passphrase']
passphrase2=data_bag_item('license_pool', 'license1')['passphrase2']
script "create ACL" do
 interpreter "bash"
 user "root"
 cwd "/tmp"
 code <<-EOH
 service #{service_name} stop
 ezncrypt-service start
 ezncrypt-access-control -a "ALLOW @mongodb * #{acl_rule1}" -P #{passphrase} -S #{passphrase2}
 ezncrypt-access-control -a "ALLOW @mongodb * #{acl_rule2}" -P #{passphrase} -S #{passphrase2}
 ezncrypt -e @mongodb #{data_dir}
 service #{service_name} start
 EOH
end
