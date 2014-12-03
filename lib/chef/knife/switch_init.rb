require 'chef/knife'

module KnifeOrgUtils
  class SwitchInit < Chef::Knife

    banner 'knife switch init'

    def dot_chef_path
      @dot_chef_path ||= ::File.expand_path( '~/.chef' )
    end

    def run
      if ::File.directory? dot_chef_path
        ui.error "Directory #{dot_chef_path} exists. Please backup and remove this directory before initializing."
        exit 1
      else
        ::Dir.mkdir dot_chef_path
      end
    end
  end
end
