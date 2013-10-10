#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Provider:: storage
#
# Copyright 2013, Needle, Inc.
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

require 'mixlib/shellout'
include Gazzang::Zncrypt::Helpers

def load_current_resource
  control = zncrypt_control_data
  storage_targets = control['keys']['targets']

  storage_targets.each do |target|
    if target['name'] == new_resource.storage_path
      @current_resource = Chef::Resource::ZncryptStorage.new(new_resource.name)
      @current_resource.storage_path(new_resource.storage_path)
      @current_resource.mount_point(new_resource.mount_point)
    end
  end

  new_resource.auth_string(
    zncrypt_format_auth_string(new_resource.passphrase, new_resource.salt)
  )
end

action :prepare do
  if @current_resource.nil?
    prepare_storage = Mixlib::ShellOut.new(
      "zncrypt-prepare #{new_resource.storage_path} #{new_resource.mount_point}",
      :input => new_resource.auth_string
    )
    prepare_storage.run_command
    prepare_storage.error!
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("zncrypt storage path #{new_resource.storage_path} on #{new_resource.mount_point} is already registered, skipping")
  end
end
