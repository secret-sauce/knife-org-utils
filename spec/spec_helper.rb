$:.unshift File.expand_path('../../lib', __FILE__)
require 'coveralls'
Coveralls.wear!

require 'chef/knife'
require 'chef/knife/org-utils'

class Chef::Knife
  include KnifeOrgUtils
end
