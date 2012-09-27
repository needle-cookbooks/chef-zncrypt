#
# Author:: Cameron Johnston (cameron@needle.com)
# Cookbook Name:: zncrypt
# Resource:: acl
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

def initialize(*args)
  super
  @action = :add
end

actions :add, :remove

attribute :permission, :kind_of => String, :default => "ALLOW", :regex => /(^ALLOW$|^DENY$)/
attribute :category,   :kind_of => String, :required => true
attribute :path,       :kind_of => String, :default => "*"
attribute :process,    :kind_of => String, :name_attribute => true
attribute :executable, :kind_of => String
attribute :children,   :kind_of => String
attribute :data_bag,   :kind_of => String, :required => true