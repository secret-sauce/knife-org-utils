require 'chef/knife'
require 'fileutils'

module KnifeOrgUtils
  class SwitchAdd < Chef::Knife

    banner 'knife switch add CHEF_RERO_DIR'

    def kit_path
      @kit_path ||= ::File.join( ::File.expand_path( @name_args[0] ), '.chef' )
    end

    def root
      @root ||= File.expand_path( '~/.chef' )
    end

    def server
      parse_config unless @server
      @server
    end

    def org
      parse_config unless @org
      @org
    end

    def user_name
      parse_config unless @user_name
      @user_name
    end

    def validation_client_name
      parse_config unless @validation_client_name
      @validation_client_name
    end

    def user_pem
      "#{user_name}.pem"
    end

    def get_kit_files
      unless ::File.exists?( kit_path ) && ::File.directory?( kit_path )
        ui.fatal "Valid starter kit is not found at #{@name_args[0]}."
        exit 1
      end
      ::Dir.glob( "#{@kit_path}/**" ).select{ | f | ::File.file? f }
    end

    def parse_config
      knife_path = ::File.join( kit_path, 'knife.rb' )
      knife_data = ::File.read( knife_path )

      %r{
        ^chef_server_url\s+"https{0,1}://(?<server>[a-zA-Z0-9-]+).*/organizations/(?<org>[a-zA-Z0-9_]+)"$
      }x =~ knife_data

      %r{
        ^node_name\s+"(?<user_name>.*)"$
      }x =~ knife_data

      %r{
        ^validation_client_name\s+"(?<validation_client_name>.*)"$
      }x =~ knife_data

      if server.nil? || org.nil? || user_name.nil?
        ui.fatal "Invalid knife.rb at #{knife_path}."
        exit 1
      end

      @server = server
      @org = org
      @user_name = user_name
      @validation_client_name = validation_client_name
    end

    def get_config_name
      ::File.join( server, org )
    end

    def get_dest_path( config_name )
      ::File.join( root, config_name )
    end

    def copy_files( files )

      server_dir = ::File.join( root, server )
      org_dir = ::File.join( server_dir, org )

      files.each do | file |
        filename = ::File.basename file

        dest_dir = ( user_pem == filename ) ? server_dir : org_dir
        dest = ::File.join( dest_dir, filename )

        ::FileUtils.copy( file, dest )
      end
    end

    def run
      unless @name_args.length == 1
        ui.fatal 'You must specify the path to started kit CHEF-RERO-DIR.'
        show_usage
        exit 1
      end

      kit_files = get_kit_files
      config_name = get_config_name
      dest_path = get_dest_path config_name

      unless ::File.directory? dest_path
        ::FileUtils.mkpath dest_path
        copy_files( kit_files )
      else
        ui.info "Configuration for #{dest_path} already exists."
      end
    end
  end
end
