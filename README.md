### Description:
This is an EXPERIMENTAL knife plugin that allows you to switch your .chef config to point to one of your orgs based on command line options

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
