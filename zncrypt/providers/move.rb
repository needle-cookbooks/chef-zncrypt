#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Provider:: move
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

def whyrun_supported?
  true
end

def load_current_resource
  new_resource.auth_string(
    zncrypt_format_auth_string(new_resource.passphrase, new_resource.salt)
  )
end

action :encrypt do
  if ::File.symlink?(new_resource.data_dir)
    # check to see if the symlink points where we expect it to, otherwise raise an error
    if ::File.readlink(new_resource.data_dir).include?(new_resource.mount_point)
      Chef::Log.info("zncrypt move: data dir #{new_resource.data_dir} is already encrypted, skipping")
    else
      Chef::Application.fatal!("zncrypt move: cannot encrypt a symlinked directory")
    end
  else
    converge_by "zncrypt move: encrypting #{new_resource.data_dir} under #{new_resource.group} in #{new_resource.mount_point}" do
      encrypt_dir = Mixlib::ShellOut.new(
        "zncrypt-move encrypt @#{new_resource.group} #{new_resource.data_dir} #{new_resource.mount_point}",
        :input => new_resource.auth_string
        )
      encrypt_dir.run_command
      encrypt_dir.error!
      new_resource.updated_by_last_action(true)
    end
  end
end

action :decrypt do
  # not yet implemented
end
