#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Provider:: acl
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

  get_rules = Mixlib::ShellOut.new("zncrypt acl --print", :input => new_resource.auth_string)
  get_rules.run_command
  @existing_rules = get_rules.stdout.split("\n")
end

action :add do
  rule_args = "#{new_resource.permission} @#{new_resource.category} #{new_resource.path} #{new_resource.process}"
  unless new_resource.shell.nil?
    rule_args = rule_args + " --shell=#{new_resource.shell}"
  end
  unless new_resource.children.nil?
    rule_args = rule_args + " --children=#{new_resource.children}"
  end

  unless @existing_rules.include?(rule_args)
    add_acl = Mixlib::ShellOut.new(
      "zncrypt acl --add --rule='#{rule_args}'",
      :input => new_resource.auth_string
    )

    converge_by("zncrypt acl: adding new rule '#{rule_args}'") do

      add_acl.run_command

      case add_acl.exitstatus
      when 0
        Chef::Log.info("zncrypt acl: rule '#{rule_args}' added successfully")
        new_resource.updated_by_last_action(true)
      else
        Chef::Application.fatal!("zncrypt acl: failed to add rule '#{rule_args}': " + add_acl.stderr.inspect)
      end
    end
  else
    Chef::Log.info("zncrypt acl: rule '#{rule_args}' already exists, skipping")
  end

end

action :remove do
  rule_args = "#{new_resource.permission} @#{new_resource.category} #{new_resource.path} #{new_resource.process}"
  unless new_resource.shell.nil?
    rule_args = rule_args + " --shell=#{new_resource.shell}"
  end
  unless new_resource.children.nil?
    rule_args = rule_args + " --children=#{new_resource.children}"
  end

  if @existing_rules.include?(rule_args)
    rm_acl = Mixlib::ShellOut.new(
      "zncrypt acl --del --rule='#{rule_args}'",
      :input => new_resource.auth_string
    )

    converge_by("zncrypt acl: removing rule '#{rule_args}'") do
      rm_acl.run_command

      case rm_acl.exitstatus
      when 0
        Chef::Log.info("zncrypt acl: rule '#{rule_args}' removed successfully")
        new_resource.updated_by_last_action(true)
      else
        Chef::Application.fatal!("zncrypt acl: failed to remove rule '#{rule_args}':\n" + rm_acl.stderr.inspect)
      end
    end
  else
    Chef::Log.info("zncrypt acl: rule '#{rule_args}' does not exist, skipping")
  end
end
