require 'chef/knife'
require 'git'

module KnifeOrgUtils
  class Switch < Chef::Knife

    banner 'knife switch'
    attr_reader :git

    option :branch,
    :short => "-b BRANCH",
    :long => "--branch BRANCH",
    :description => 'Name of the git branch containing desired config file and pems',
    :default => nil

    option :list,
    :short => "-l",
    :long => "--list",
    :description => 'List of all the git branches',
    :default => nil
	
    option :status,
    :short => "-t",
    :long => "--status",
    :description => 'List uncommitted changes',
    :default => nil

    option :commit,
    :short => "-m",
    :long => "--commit",
    :description => 'commits all changes to git',
    :default => nil

    def run
      @git = ::Git.open('~/.chef')
      status = @git.status
      case
        when config[:branch]
          begin
            @git.checkout("#{config[:branch]}")
            puts "Switched to branch #{config[:branch]}"
          rescue Git::GitExecuteError => e
            puts e.message
          end

        when config[:status]
          status.changed.keys.each do | k |
            puts "File #{k} has changed"
          end
          status.added.keys.each do | k |
            puts "File #{k} has been added"
          end
          status.deleted.keys.each do | k |
            puts "File #{k} has been deleted"
          end

        when config[:commit]
          @git.add(:all=>true)   
          files_affected = status.changed.keys + status.added.keys + status.deleted.keys
          @git.commit("Committing changes to files #{files_affected}")
          
        when config[:list]
          puts 'Available Branches: '
          puts "#{@git.branches}"
        else show_usage
      end
    end
  end
end
