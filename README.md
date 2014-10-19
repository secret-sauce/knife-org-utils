# knife org utils
[![Gem Version](https://badge.fury.io/rb/knife-org-utils.svg)](http://badge.fury.io/rb/knife-org-utils) [![Build Status](https://travis-ci.org/secret-sauce/knife-org-utils.svg?branch=master)](https://travis-ci.org/secret-sauce/knife-org-utils) [![Dependency Status](https://gemnasium.com/secret-sauce/knife-org-utils.svg)](https://gemnasium.com/secret-sauce/knife-org-utils)


### Description:
This is an EXPERIMENTAL knife plugin that allows you :

- to switch your .chef config files and keys to point to one of your orgs based on command line options
- to display information from the `knife.rb` config file in knife's configuration file search path.

## Installation

This knife plugin is packaged as a gem. To install it, clone this
git repository and run the following command from inside the cloned repo:

    rake install


## Requirements
  * create a `~/.chef` directory on your workstation and make it a git repo
  * create branches, each branch containing the appropriate config file and pem files pointing to a specific org


## Subcommands

### `knife switch BRANCH`
checkout to this git branch containing your chef credentials, provided it exists

### `knife switch list`
list of available branches in `~/.chef` folder

### `knife info [options]`
prints the current chef server referenced by your `~/.chef/knife.rb`

*Options*

  * `--tiny`: Show concise information in oneline
  * `--medium`: Show important information in oneline
  * `--long`: Show all information in multi-lines
