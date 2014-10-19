require 'chef/knife'
require 'git'

module KnifeOrgUtils
  class Switch < Chef::Knife

    banner 'knife switch BRANCH'

    def run
      @git = ::Git.open( '~/.chef' )
      unless @name_args.length == 1
        ui.fatal 'You must specify an BRANCH name'
        show_usage
        exit 1
      end

      begin
        @git.checkout( "#{@name_args[0]}" )
        ui.msg "Switched to branch #{@name_args[0]}"
      rescue Git::GitExecuteError => e
        ui.error e.message
      end
    end
  end
end
