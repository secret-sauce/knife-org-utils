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

  class Info < Chef::Knife

    category 'CHEF KNIFE INFO'
    banner 'knife info'

    option :tiny,
           :long => '--tiny',
           :description => 'Print concise information in oneline',
           :boolean => true | false

    option :medium,
           :long => '--medium',
           :description => 'Print important information in oneline',
           :boolean => true | false

    option :long,
           :long => '--long',
           :description => 'Print all information in multiple lines',
           :boolean => true | false,
           :default => true

    def run
      read_config_data

      unless @config_file.nil?
        case
          when config[:tiny] then ui.msg(tiny_print)
          when config[:medium] then ui.msg(medium_print)
          else ui.msg(long_print)
        end
      end
    end

    def read_config_data
      @config_file = Chef::Knife.locate_config_file

      uri = URI(server_url)
      @host = uri.host

      %r(.*/organizations/(?<org>.*)$) =~ uri.path
      @organization = org || ''
    end

    def user_string
      (username != ENV['USER']) ? "#{username}@" : ''
    end

    def tiny_print
      %r(^(?<host>[a-zA-Z0-9-]+)\..*$) =~ @host
      "#{user_string}#{host}/#{@organization}"
    end

    def medium_print
      "#{user_string}#{@host}/#{organization}"
    end

    def long_print
      <<-VERBOSE.gsub(/^\s+/, '')
      Host: #{@host}
      Username: #{username}
      Organization: #{@organization}
      Config File: #{@config_file}
      VERBOSE
    end

    attr_reader :host, :organization, :user, :config_file_location
  end
end
