#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Provider:: acl
#
# Copyright 2012, Needle, Inc.
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

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

action :add do

  license_data = load_license(@new_resource.data_bag,node['hostname'])

  if license_data['passphrase']
    auth_args = "-P #{license_data['passphrase']}"
    rule_args = "#{@new_resource.permission} @#{@new_resource.category} #{@new_resource.path} #{@new_resource.process}"
    if license_data['salt']
      auth_args = auth_args + " -S #{license_data['salt']}"
    end
    cmd_args = "#{auth_args} -a \"#{rule_args}\""
    unless @new_resource.executable.nil?
      cmd_args = cmd_args + " --exec=#{@new_resource.executable}"
    end
    unless @new_resource.children.nil?
      cmd_args = cmd_args + " --children=#{@new_resource.children}"
    end
  else
    Chef::Log.fatal("zncrypt acl: failed to load passphrase from license data from the #{@new_resource.data_bag}, cannot proceed")
    raise
  end

  cmd_result = Chef::Mixin::ShellOut.shell_out("ezncrypt-access-control #{cmd_args}")

  case cmd_result.exitstatus
  when 0
    Chef::Log.info("zncrypt acl: rule '#{rule_args}' added successfully")
    @new_resource.updated_by_last_action(true)
  when 1
    if cmd_result.stderr == "ERROR: Rule already exists\n"
      Chef:Log.info("zncrypt acl: rule '#{rule_args}' already exists")
      @new_resource.updated_by_last_action(false)
    else
      Chef::Log.fatal("zncrypt acl: failed to add rule '#{rule_args}':\n" + cmd_result.stderr.inspect)
      raise
    end
  end
end

action :remove do

  license_data = load_license(@new_resource.data_bag,node['hostname'])

  if license_data['passphrase']
    auth_args = "-P #{license_data['passphrase']}"
    rule_args = "#{@new_resource.permission} @#{@new_resource.category} #{@new_resource.path} #{@new_resource.process}"
    if license_data['salt']
      auth_args = auth_args + " -S #{license_data['salt']}"
    end
    cmd_args = "#{auth_args} -d \"#{rule_args}\""
    unless @new_resource.executable.nil?
      cmd_args = cmd_args + " --exec=#{@new_resource.executable}"
    end
    unless @new_resource.children.nil?
      cmd_args = cmd_args + " --children=#{@new_resource.children}"
    end
  else
    Chef::Log.fatal("zncrypt acl: failed to load passphrase from license data from the #{@new_resource.data_bag}, cannot proceed")
    raise
  end

  cmd_result = Chef::Mixin::ShellOut.shell_out("ezncrypt-access-control #{cmd_args}")

  case cmd_result.exitstatus
  when 0
    Chef::Log.info("zncrypt acl: rule '#{rule_args}' removed successfully")
    @new_resource.updated_by_last_action(true)
  when 1
    if cmd_result.stderr == "ERROR: Rule does not exists\n"
      Chef:Log.info("zncrypt acl: rule '#{rule_args}' already exists")
      @new_resource.updated_by_last_action(false)
    else
      Chef::Log.fatal("zncrypt acl: failed to remove rule '#{rule_args}':\n" + cmd_result.stderr.inspect)
      raise
    end
  end
end
