Description
===========

Installs zNcrypt 3.x and prerequistes from packages

Requirements
============

Platform
--------

* Debian, Ubuntu
* CentOS, Red Hat, Fedora

Tested on:

* Ubuntu 10.04, 12.04
* CentOS 6.2

Cookbooks
---------

Requires apt and yum cookbooks to add gpg keys and gazzang repo.
Requires openssl cookbook to generate a strong passhrase

 `git clone git://github.com/opscode-cookbooks/apt
 knife cookbook upload apt`

 `git clone git://github.com/opscode-cookbooks/yum
 knife cookbook upload yum`

 `git clone git://github.com/opscode-cookbooks/openssl
 knife cookbook upload openssl`

The cassandra recipe depends on Java, by default is OpenJDK

 `git clone git://github.com/opscode-cookbooks/java
 knife cookbook upload java`

Requires a C compiler for Dynamic Kernel Module compilation.


Attributes
==========

See `attributes/default.rb` for default values

* `node["zncrypt"]["zncrypt_mount"]` - mount point for zncrypt, default `/var/lib/ezncrypt/ezncrypted`.
* `node["zncrypt"]["zncrypt_storage"]` - directory to store encrypted data, default `/var/lib/ezncrypt/storage`.
* `node["zncrypt"]["zncrypt_admin_email"]` - email address of zNcrypt license key Administrator`.

Usage
=====

This cookbook provides both reusable resources (LWRPs) for managing zncrypt activation, acls and storage, and a set of recipes which configure specific zncrypt implementation scenarios.

You may wish to include the resources and/or recipes from this cookbook inside another cookbook in order to make use of zncrypt as part of your organization's cookbooks for configuring proprietary applications.

Recipes
=======

The following recipes were written prior to the authoring of the included LWRPs, and have not yet been updated to use those resources.

    include_recipe "zncrypt::default" - installs, configures and activates zncrypt
    include_recipe "zncrypt::zncrypt" - installs only zncrypt
    include_recipe "zncrypt::cassandra" -installs cassandra and configures zncrypt
    include_recipe "zncrypt::mongodb" -installs mongodb and configures zncrypt

This will install zNcrypt 3.x, dkms and the required kernel headers.

Data Bag
========

Add a databag for each server with a Gazzang license and activation code

  "data_bag": "masterkey_bag",
  "name": "masterkey_bag",
  "json_class": "Chef::DataBagItem",
  "chef_type": "data_bag_item",
  "raw_data": {
    "id": "key1",
    "passphrase": "yourpassphrase",
    "passphrase2": "yourpassphrase",
  }

Resources
=========

When using these resources in a wrapper or application cookbook, you should:

* list 'zncrypt' cookbook as a dependency in your cookbook's metadata.rb
* use include_recipe 'zncrypt::zncrypt' recipe prior to invoking any of these resources

Generally you will need to use a combination of one or more of each of the following resources in order to realize a functional zNcrypt installation. For an example, please see the zncrypt-test cookbook under this cookbook's 'test' directory.

## `zncrypt_license`

Provides `:register` action for registering and requesting activation for zNcrypt licenses on nodes managed by Chef.

zNcrypt 3.3.x added a new single-step registration mode known as "regauth" mode. Whereas the "classic" two-step registration mode requires administrators to authorize license activiation by clicking a link sent via email, the new "regauth" mode allows activation to happen without this second authorization step by using an organization name and auth code. These credentials should be made available to you from Gazzang support.

Classic two-step activation remains the default, although this may change in the future.

### Attributes

`client` - name of the client to register (e.g. node hostname), this is included in activation request.
`admin_email` - email address to use when requesting license activation
`passphrase` - secret passphrase
`salt` - a.k.a. passphrase2
`regmode` - registration mode, accepts either :classic or :regauth, defaults to :classic
`org` - organization name, for use with regauth registration mode
`auth` - organization auth key, for use with regauth registration mode

### Usage

"Classic" registration mode

```ruby
zncrypt_license node['fqdn'] do
  admin_email 'admin@example.com'
  passphrase  'changeme123'
  salt        'secret'
  action      :activate
end
```

"Regauth" registraion mode

```ruby
zncrypt_license node['fqdn'] do
  passphrase 'changeme123'
  salt       'secret'
  orgname    'mycorp'
  authcode   'jentyefDykkiskijOvTee'
  regmode    :regauth
  action     :activate
end
```

## `zncrypt_acl`

Provides `:add` and `:remove` actions for adding and removing zNcrypt ACLs

### Attributes
`process` -
`permission` - 'ALLOW' or 'DENY' action
`group` -
`path` -
`shell` -
`children` -
`passphrase` - secret passphrase
`salt` - a.k.a. passphrase2

### Usage
```ruby
zncrypt_acl '/bin/ls' do
  group      'trusted'
  path       '*'
  permission 'ALLOW'
  shell      '/bin/bash'
  passphrase 'changeme123'
  salt       'secret'
end
```

## `zncrypt_storage`

Provides `:prepare` action for creating and mounting zNcrypt file systems

### Attributes
`storage_path` -
`mount_point` -
`passphrase` - secret passphrase
`salt` - a.k.a. passphrase2

### Usage

```ruby
zncrypt_storage '/var/lib/zncrypt/storage' do
  mount_point   '/var/lib/zncrypt/zncrypted'
  passphrase    'changeme123'
  salt          'secret'
  action        :prepare
end
```

## `zncrypt_move`

Provides `:encrypt` action for moving unencrypted data to a zNcrypt file system (e.g. one created by Chef using a `zncrypt_storage` resource)

### Attributes

`data_dir` -
`mount_point` -
`group` -
`passphrase` - secret passphrase
`salt` - a.k.a. passphrase2


### Usage

```ruby
zncrypt_move '/data/secrets' do
  mount_point '/var/lib/zncrypt/zncrypted'
  group       'trusted'
  passphrase  'changeme123'
  salt        'secret'
  action      :encrypt
end

```

TODO
====

[ ] Add support for RSA keys to existing zncrypt resources


License and Author
==================

Author:: Eddie Garcia (<eddie.garcia@gazzang.com>)
Author:: Cameron Johnston (<cameron@rootdown.net>)

Copyright:: 2012 Gazzang, Inc
Copyright:: 2013 Needle, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
