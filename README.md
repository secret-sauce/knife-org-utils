# knife org utils
[![Gem Version](https://badge.fury.io/rb/knife-org-utils.svg)](http://badge.fury.io/rb/knife-org-utils) [![Build Status](https://travis-ci.org/secret-sauce/knife-org-utils.svg?branch=master)](https://travis-ci.org/secret-sauce/knife-org-utils) [![Dependency Status](https://gemnasium.com/secret-sauce/knife-org-utils.svg)](https://gemnasium.com/secret-sauce/knife-org-utils)


## :no_entry: Warning :no_entry:

If you are using pre 1.0.x version of `knife-org-utils, please follow this instructions for migration.

    git clone git@github.com:secret-sauce/knife-org-utils.git
    gem install knife-org-utils -v 1.1.1
    ./knife-org-utils/bin/migrate

This script will migrate your existing git based `~/.chef` to the new directory layout. your old `~/.chef` folder will be backed up at `/tmp/chef-repo/.chef`.

## Description:
This is an EXPERIMENTAL knife plugin that allows you :

- to switch config files and keys in `~/.chef` quickly from command line.
- to display information from the `knife.rb` config file in knife's configuration file search path.

## Installation

This knife plugin is packaged as a gem and is available on [rubygems.org](http://rubygems.org/gems/knife-org-utils).

    gem install knife-org-utils

## Requirements
:warning: backup your current `~/.chef` directory :warning:

## Available Subcommands and what they do for you

### `knife switch init`
Initializes your `.chef` directory.
- - -

### `knife switch add $CHEF_RERO_DIR`
Imports `.chef` files from `$CHEF_RERO_DIR/.chef` into `~/.chef` folder. The name of the imported CONFIG will be based on the `chef_server_url` in the `knife.rb` file. Starter Kit is a valid chef-repo directory.

*Options*
  * `--overwrite`: Overwrites configuration files if they exists

- - -

### `knife switch CONFIG`
switches the configuration in `~/.chef` to the named CONFIG
- - -

### `knife switch list`
list of available CONFIGS in `~/.chef` folder.
- - -

### `knife info [options]`
prints the current chef server referenced by your `~/.chef/knife.rb`.

*Options*

  * `--tiny`: Show concise information in oneline
  * `--medium`: Show important information in oneline
  * `--long`: Show all information in multi-lines
