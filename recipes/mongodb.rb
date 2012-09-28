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

include_recipe "mongodb::default"

zncrypt_acl which('chef-client').first do
  category "mongodb"
  path "*"
  permission "ALLOW"
  executable "/bin/bash"
  children node['languages']['ruby']['ruby_bin']
  data_bag node['zncrypt']['license_pool']
end

%w{mongod mkdir}.each do |proc|
  zncrypt_acl which(proc).first do
    category "mongodb"
    path "*"
    permission "ALLOW"
    data_bag node['zncrypt']['license_pool']
  end
end

unless FileTest.directory?(node['zncrypt']['zncrypt_mount']) and Dir.entries(node['zncrypt']['zncrypt_mount']).include?('mongodb')
  service "mongodb" do
    action :stop
  end

  execute "encrypt mongodb data" do
    command "ezncrypt -e @mongodb #{node['mongodb']['dbpath']}"
    notifies :start, "service[mongodb]", :immediately 
  end
end