require 'chef/knife'
require 'git'

module KnifeOrgUtils
  class SwitchAdd < Chef::Knife

    banner 'knife switch add CHEF_RERO_DIR'

    def kit_path
      @kit_path ||= ::File.join( ::File.expand_path( @name_args[0] ), '.chef' )
    end

    def dot_chef_path
      @dot_chef_path ||= File.expand_path( '~/.chef' )
    end

    def git
      git = ::Git.open( dot_chef_path )
    end

    def run
      unless @name_args.length == 1
        ui.fatal 'You must specify the path to started kit CHEF-RERO-DIR'
        show_usage
        exit 1
      end

      kit_files = get_kit_files
      branch_name = get_branch_name

      unless branch_exists? branch_name
        checkout( branch_name )
        clean_files
        copy_files( kit_files )
        commit( branch_name )
      else
        ui.info "Branch for #{branch_name} already exists"
      end
    end

    def get_kit_files
      unless ::File.exists?( kit_path ) && ::File.directory?( kit_path )
        ui.fatal "Valid starter kit is not found at #{@name_args[0]}"
        exit 1
      end
      ::Dir.glob( "#{@kit_path}/**" ).select{ | f | ::File.file? f }
    end

    def get_branch_name
      knife_path = ::File.join( kit_path, 'knife.rb' )
      knife_data = ::File.read( knife_path )

      %r(^chef_server_url\s+"https{0,1}://(?<host>[a-zA-Z0-9-]+).*/organizations/(?<org>[a-zA-Z0-9_]+)"$) =~ knife_data

      if host.nil? || org.nil?
        ui.fatal "Invalid knife.rb at #{knife_path}"
        exit 1
      end

      "#{host}/#{org}"
    end

    def branch_exists?( branch_name )
      git.branches.local.find do | branch |
        branch.name == branch_name
      end
    end

    def checkout( branch_name )
      begin
        git.branch( branch_name ).checkout
      rescue Git::GitExecuteError => e
        ui.fatal e.message
        exit 1
      end
    end

    def copy_files( files )
      files.each do | file |
        filename = ::File.basename file
        dest = ::File.join( dot_chef_path, filename )
        ::FileUtils.copy( file, dest )
      end
    end

    def clean_files
      files = ::Dir.glob( "#{dot_chef_path}/**" ).select{ | f | ::File.file? f }
      files.each do |file|
        ::File.unlink( file )
      end
    end

    def commit( branch_name )
      begin
        git.add( :all=>true )
        git.commit( "Adding #{branch_name} from #{kit_path}" )
      rescue Git::GitExecuteError => e
        ui.fatal e.message
        exit 1
      end
    end
  end
end
