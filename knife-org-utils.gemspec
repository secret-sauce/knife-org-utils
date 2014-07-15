$:.push File.expand_path("../lib", __FILE__)
require 'knife-org-utils/version'

Gem::Specification.new do |spec|

  spec.name = 'knife-org-utils'
  spec.version = KnifeOrgUtils::VERSION
  spec.summary = 'knife org'
  spec.description = 'Manages your .chef org, and provides info about your chef config'

  spec.authors = ['Venkat Venkataraju','Shruthi Venkateswaran']
  spec.email = ['ven@yahoo-inc.com','shruthiv@yahoo.com']
  spec.homepage = 'https://github.com/shruthi-venkateswaran/knife-org-utils.git'

  spec.files = %w(README.md) + Dir.glob('lib/**/*') + Dir.glob('bin/*')
  spec.require_path = 'lib'

  spec.required_ruby_version = '>= 1.9'

  spec.add_dependency 'chef'
  spec.add_dependency 'git'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
