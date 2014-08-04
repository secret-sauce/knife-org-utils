# knife org utils
[![Gem Version](https://badge.fury.io/rb/knife-org-utils.svg)](http://badge.fury.io/rb/knife-org-utils) [![Build Status](https://travis-ci.org/secret-sauce/knife-org-utils.svg?branch=master)](https://travis-ci.org/secret-sauce/knife-org-utils) [![Dependency Status](https://gemnasium.com/secret-sauce/knife-org-utils.svg)](https://gemnasium.com/secret-sauce/knife-org-utils)


### Description:
This is an EXPERIMENTAL knife plugin that allows you :

- to switch your .chef config files and keys to point to one of your orgs based on command line options
- to display information from the `knife.rb` config file in knife's configuration file search path.

## Installation

This knife plugin is packaged as a gem. To install it, clone this
git repository and run the following command:

    rake install


## Requirements
  * create a `~/.chef` directory on your workstation and make it a git repo
  * create branches, each branch containing the appropriate config file and pem files pointing to a specific org


## Subcommands

### `knife switch [options]`

*Options*

  * `--branch`: checkout to this git branch, provided it exists
  * `--list`: list of available branches
  * `--status`: check the files that are modified/added/deleted
  * `--commit`: commit all changes to that branch

### `knife info [options]`

*Options*

  * `--tiny`: Show concise information in oneline
  * `--medium`: Show important information in oneline
  * `--long`: Show all information in multi-lines
