$:.unshift File.expand_path('../../lib', __FILE__)

require 'chef/knife'
require 'chef/knife/info'
require 'chef/knife/switch'
require 'chef/knife/switch_list'
require 'chef/knife/switch_add'

class Chef::Knife
  include KnifeOrgUtils
end
