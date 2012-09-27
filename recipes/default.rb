#
# Author:: Eddie Garcia (<eddie.garcia@gazzang.com>)
# Cookbook Name:: zncrypt
# Recipe:: default
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
# All rights reserved - Do Not Redistribute
#

# installs zncrypt
include_recipe "zncrypt::zncrypt"

# configure the required directories
config_dirs = "-m #{node['zncrypt']['zncrypt_mount']} -s #{node['zncrypt']['zncrypt_storage']}"

case node['platform_family']
when "rhel","fedora"
 cmd = "ezncrypt-configure-directories #{config_dirs} -l"
when "debian"
 cmd = "ezncrypt-configure-directories #{config_dirs} -a"
end

service "ezncrypt" do
  action :stop
end

execute "config dirs" do
  command cmd
end

include_recipe "zncrypt::activate"

service "ezncrypt" do
  action [:enable, :start]
end