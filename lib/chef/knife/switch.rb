require 'chef/knife'

module KnifeOrgUtils
  class Switch < Chef::Knife

    banner 'knife switch CONFIG'

    def root
      @root ||= File.expand_path( '~/.chef' )
    end

    def config_name
      @config_name ||= @name_args[0]
    end

    def server
      parse_config_name unless @server
      @server
    end

    def org
      parse_config_name unless @org
      @org
    end

    def parse_config_name
      %r{^(?<server>[a-z_]+)/(?<org>[a-z_]+)$} =~ config_name
      @server = server
      @org = org
    end

    def source_knife_config
      @source_knife_config ||= File.join( root, config_name, 'knife.rb' )
    end

    def dest_knife_config
      ::File.join( root, 'knife.rb' )
    end

    def config_methods
      %w(
        log_level
        log_location
        node_name
        client_key
        validation_client_name
        validation_key
        chef_server_url
      )
    end

    def run
      unless @name_args.length == 1
        ui.fatal 'You must specify an CONFIG name.'
        show_usage
        exit 1
      end

      unless ::File.exists? source_knife_config
        ui.fatal "#{source_knife_config} not found for #{config_name} config."
        show_usage
        exit 1
      end

      File.open( dest_knife_config, 'w' ) do | output |

        server_dir = ::File.join( root, server )
        org_dir = ::File.join( server_dir, org )

        output.write( "# Generated by knife-org-utils for config #{config_name}\n" )
        output.write( "server_dir = '#{server_dir}'\n" )
        output.write( "org_dir = '#{org_dir}'\n" )

        File.foreach( source_knife_config ) do | line |
          %r{^(?<method>[a-zA-Z0-9_]+)\s+(?<param>.*)$} =~ line
          if config_methods.include? method
            dest_dir = ( method == 'client_key' ) ? 'server_dir' : 'org_dir'
            param.gsub!( '#{current_dir}', "\#\{#{dest_dir}\}" )
            output.write "#{method} #{param}\n"
          end
        end
      end
      ui.msg "Switched to #{config_name} knife config."
    end
  end
end
