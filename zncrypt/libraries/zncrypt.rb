#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Library:: zncrypt
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

require 'chef/mixin/shell_out'
require 'json'

module Gazzang
  module Zncrypt
    module Helpers

      def zncrypt_mounted?(path)
        case Chef::Mixin::ShellOut.shell_out("grep #{path} /proc/mounts").exitstatus
        when 1
          false
        when 0
          true
        end
      end

      def zncrypt_registered?
        # The following is authorative, but its dog slow.
        #case Chef::Mixin::ShellOut.shell_out("zncrypt status -r").exitstatus
        #when 0
        #  true
        #else
        #  false
        #end
        begin
          control = self.zncrypt_control_data
          return control['keys'].has_key?('master') ? true : false
        rescue => e
          Chef::Log.warn("unable to load zncrypt control data: #{e}")
          return false
        end
      end

      def zncrypt_key_type
        control = self.zncrypt_control_data
        begin
          case control['keys']['master']['type']
          when 'single-passphrase'
            return :single
          when 'dual-passphrase'
            return :dual
          when 'rsa'
            Chef::Application.fatal!("detected rsa key type configuration, not yet supported")
          else
            raise "key is neither single-passphrase nor dual-passphrase"
          end
        rescue => e
          Chef::Application.fatal!("could not determine zncrypt key type:\n#{e}")
        end
      end

      def zncrypt_format_auth_string(passphrase, salt)
        case self.zncrypt_key_type
        when :single
          auth_string = "#{passphrase}\n"
        when :dual
          if passphrase && salt
            auth_string = [passphrase, salt].join("\n")
          else
            Chef::Application.fatal!("zncrypt key type is 'dual passphrase' but you did not provide a second passphrase (salt)")
          end
        end
        return auth_string
      end

      def zncrypt_control_data(control_file="/etc/zncrypt/control")
        JSON.parse(IO.read(control_file))
      end

    end
  end
end
