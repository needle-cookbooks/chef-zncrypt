#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Provider:: license
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
include ::Gazzang::Zncrypt::Helpers

action :activate do

  unless ::File.exists?('/etc/zncrypt/control') && zncrypt_registered?

    case new_resource.salt
    when NilClass
      @register_auth_string = [new_resource.passphrase, new_resource.passphrase].join("\n")
      @activate_auth_string = "#{new_resource.passphrase}\n"
      @register_args = "--key-type=single-passphrase --clientname=#{new_resource.client}"
    when
      if new_resource.passphrase && new_resource.salt
        @register_string = [new_resource.passphrase, new_resource.passphrase, new_resource.salt, new_resource.salt].join("\n")
        @activate_string = [new_resource.passphrase, new_resource.salt].join("\n")
        @register_args = "--key-type=dual-passphrase --clientname=#{new_resource.client}"
      else
        Chef::Application.fatal!("zncrypt key type is 'dual passphrase' but you did not provide a second passphrase (salt)")
      end
    end

    directory "/var/log/zncrypt"

    # the following make use of printf to avoid logging the passphrase
    register_cmd = Mixlib::ShellOut.new(
      "zncrypt register #{@register_args}",
      :input => @register_auth_string,
      :log_level => :debug
    )
    register_cmd.run_command
    register_cmd.error!

    activate_cmd = Mixlib::ShellOut.new(
      "zncrypt request-activation --contact=#{new_resource.admin_email}",
      :input => @activate_auth_string,
      :log_level => :debug
    )
    activate_cmd.run_command
    activate_cmd.error!

    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info('zncrypt is already actviated, skipping activation process.')
  end

end
