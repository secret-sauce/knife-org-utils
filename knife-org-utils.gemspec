$:.push File.expand_path("../lib", __FILE__)
require 'knife-org-utils/version'

Gem::Specification.new do |spec|

  spec.name = 'knife-org-utils'
  spec.version = KnifeOrgUtils::VERSION
  spec.summary = 'knife org'
  spec.description = 'Manages your .chef org, and provides info about your chef config'

  spec.authors = ['Venkat Venkataraju', 'Shruthi Venkateswaran']
  spec.email = ['ven@yahoo-inc.com', 'shruthiv@yahoo-inc.com']
  spec.homepage = 'https://github.com/secret-sauce/knife-org-utils.git'

  spec.files = %w(README.md) + Dir.glob('lib/**/*') + Dir.glob('bin/*')
  spec.require_path = 'lib'

  spec.required_ruby_version = '~> 2.0'

  spec.add_runtime_dependency 'chef', '~> 11.16', '>= 11.16.4'
  spec.add_development_dependency 'bundler', '~> 0'
  spec.add_development_dependency 'rake', '~> 0'
  spec.add_development_dependency 'rspec', '~> 0'

  spec.license = 'MIT'

  # prereleases from Travis CI
  if ENV['CI']
    digits = spec.version.to_s.split '.'
    digits[-1] = digits[-1].to_s.succ
    spec.version = digits.join('.') + ".beta.#{ENV['TRAVIS_JOB_NUMBER']}"
  end
end
