require 'chef/knife'
require 'git'

module KnifeOrgUtils
  class SwitchList < Chef::Knife

    banner 'knife switch list'

    def run
      @git = ::Git.open( '~/.chef' )
      ui.msg @git.branches.local
    end
  end
end
