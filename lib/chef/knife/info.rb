require 'chef/knife'

module KnifeOrgUtils
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
