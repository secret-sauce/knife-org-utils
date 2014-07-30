$:.unshift File.expand_path('../../lib', __FILE__)
require 'coveralls'
Coveralls.wear!

require 'chef/knife'
require 'chef/knife/info'
require 'chef/knife/switch'

class Chef::Knife
  include KnifeOrgUtils
end
