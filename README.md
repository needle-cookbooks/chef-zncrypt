# Description

Installs zNcrypt and prerequistes

# Requirements

## Platform

* Debian, Ubuntu
* CentOS, Red Hat, Fedora

Tested on:

* Ubuntu 10.04, 11.10
* CentOS 6.2

## Cookbooks

Requires apt and yum cookbooks to add gpg keys and the gazzang package repo.
Requires openssl cookbook to generate a strong passhrase.

All dependencies are described in the included Berksfile. More information on Berkshelf can be found here.

# Attributes

See `attributes/default.rb` for default values

* `node['zncrypt']['zncrypt_mount']` - mount point for zncrypt, default `/var/lib/ezncrypt/ezncrypted`.
* `node['zncrypt']['zncrypt_storage']` - directory to store encrypted data, default `/var/lib/ezncrypt/storage`.
* `node['zncrypt']['use_default_activation']` - toggles whether or not `activate` recipe is used, default `true`

# Recipes

`zncrypt::default` - installs, configures and activates zncrypt
`zncrypt::zncrypt` - installs only zncrypt
`zncrypt::activate` - activates the zncrypt installation (depends on `default` recipe)
`zncrypt::cassandra` - installs cassandra and configures zncrypt
`zncrypt::mongodb` - installs mongodb and configures zncrypt

# Resources

## `zncrypt_license`

This LWRP provides a flexible mechanism for activating zNcrypt licenses on nodes managed by Chef. 

### Attributes

* `license` (optional) - the license id to be used. a license is not provided, this LWRP will attempt to retrieve one from a data bag, or failing that, automatically register the node using a 1hr trial license.
* `activation_code` (optional) - the corresponding activation code for the `licence`
* `passphrase` (required) - the passphrase to be associated with this license
* `salt` (optional) - a second passphrase to be associated with this license
* `data_bag` (optional, defaults to `zncrypt_license_pool`) - the name of the data bag which containing the `license_index` and where automatically generated license data is stored.
* `allow_trial` (optional, defaults to `true`) - control whether or not nodes will be allowed to automatically activate using a trial license (prevent surprises in live environments).

### Usage example

The simplest example of using this LWRP might be:

```ruby
zncrypt_license node['hostname'] do
  passphrase "seatecastronomy"
end
```

Assuming the node does not already have a zNcrypt license activated, this example would attempt to automatically retrieve a `license` and `activation_code` pair from the `license_index` data bag item in the `zncrypt_license_pool` data bag. If no license/activation code pairs are present in the `license_index` then the default behavior is to activate the node with a time-limited trial license.

The `activate` recipe in this cookbook uses a similar approach, but uses the OpenSSL cookbook's `secure_password` function to automatically generate a passphrase and salt.

Regardless of whether a license and activation code are obtained directly via the LWRP attributes, retrieved automatically from the data bag or the default trial license is used, the LWRP will try to store information about the activated license (including passphrase, salt, etc) in the same data bag where the `license_index` is located. The license ID and activation codes are also added to the node's attributes. This makes it possible to search out which licenses are allocated to nodes via the data bag and/or the node attributes.

### The `license_index` data bag item

When using a data bag to provide a pool of available licenses to the `zncrypt_license` LWRP, a `licence_index` item must be present in the data bag. The structure of the `license_index` is pretty simple:

```json
{
  "id": "licence_index",
  "licenses": {
    "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX": "123412341234"
  }
}
```

The `licenses` hash should contain license IDs as keys and the license's activation code as the corresponding value. The `zncrypt_license` LWRP will automatically rewrite the license pool data bag as new nodes are activated, removing allocated licenses from the license index and creating a new data bag item to store details about the activated license.

## `zncrypt_acl`

This LWRP is a wrapper for the `ezncrypt-access-control` command. Using this LWRP requires the node's zNcrypt passphrase (and optional salt) to be stored in a data bag following the format used by the `zncrypt_license` LWRP.

### Attributes
* `process` (name attribute) - full path to the executable binary which the ACL should apply to
* `data_bag` (optional) - specifies the data bag to use for retreiving license/passphrase data (defaults to 'zncrypt_license_pool')
* `permission` - "ALLOW" or "DENY", defaults to "ALLOW"
* `category` (required) - the category or group for this ACL
* `path` - access path permissions (i.e. "*" or "*.txt", defaults to "*")
* `executable` (optional) - specifies the full path to the process that executes `process` (e.g. for shell scripts)
* `children` (optional) - specifies the child processes executed by `process` when run from `executable`

### Usage example
```ruby
zncrypt_acl "/usr/bin/mongod" do
  group "mongodb"
  path "*"
  permission "ALLOW"
end
```

# CHANGELOG

* Implemented `zncrypt_license` and `zncrypt_acl` LWRPs. Rearranged most of the recipes.

# TODO

* Add support for encrypted data bags to `zncrypt_license` LWRP
* Add support for RSA key files

# License and Author

Author:: Eddie Garcia (<eddie.garcia@gazzang.com>)
Author:: Cameron Johnston (<cameron@needle.com>)

Copyright:: 2012 Gazzang, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
