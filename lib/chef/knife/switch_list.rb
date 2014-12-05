require 'chef/knife'

module KnifeOrgUtils
  class SwitchList < Chef::Knife

    banner 'knife switch list'

    def root
      @root ||= File.expand_path( '~/.chef' )
    end

    def current_config
      parse_knife_rb unless @current_config
      @current_config
    end

    def parse_knife_rb
      knife_rb = ::File.join( root, 'knife.rb' )
      knife_data = ::File.read( knife_rb )
      %r{
        ^chef_server_url\s+"https{0,1}://(?<server>[a-zA-Z0-9-]+).*/organizations/(?<org>[a-zA-Z0-9_]+)"$
      }x =~ knife_data

      @current_config = "#{server}/#{org}"
    end

    def run
      Dir.glob("#{root}/*/*/").each do | dir |
        config_name = dir.gsub(%r{^#{root}/}, '').chomp('/')

        current = if ( current_config == config_name )
          "\xF0\x9F\x8D\xB4  "
        else
          "   "
        end
        ui.msg "#{current}#{config_name}"
      end
    end
  end
end
