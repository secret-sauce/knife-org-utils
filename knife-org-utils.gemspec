$:.push File.expand_path("../lib", __FILE__)
require 'knife-org-utils/version'

Gem::Specification.new do |spec|

  spec.name = 'knife-org-utils'
  spec.version = KnifeOrgUtils::VERSION
  spec.summary = 'knife org'
  spec.description = 'Manages multiple chef server/org configuration files in the .chef folder.'
  spec.authors = ['Venkat Venkataraju', 'Shruthi Venkateswaran']
  spec.email = ['ven@yahoo-inc.com', 'shruthiv@yahoo-inc.com']
  spec.homepage = 'https://github.com/secret-sauce/knife-org-utils.git'
  spec.post_install_message = <<-MSG.gsub /^\s{4}/, ''
      \e[1;33;40m!!! Warning !!!\e[0m
      \e[0;36;40mPlease ignore this message if you do not use 'knife switch'\e[0m
      Pre 1.0.0 version used git to manage the ~/.chef folder. Version 1.0.x and
      above will not use git to manage the ~/.chef directory. Please backup your
      ~/.chef directory before adding new configurations.
      More info: https://github.com/secret-sauce/knife-org-utils/blob/master/README

  MSG

  spec.files = %w(README.md) + Dir.glob('lib/**/*') + Dir.glob('bin/*')
  spec.require_path = 'lib'

  spec.required_ruby_version = '~> 2'

  spec.add_runtime_dependency 'chef', '~> 11.16', '>= 11.16.4'
  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'

  spec.license = 'MIT'

  # prereleases from Travis CI
  if ENV['CI']
    digits = spec.version.to_s.split '.'
    digits[-1] = digits[-1].to_s.succ
    spec.version = digits.join('.') + ".beta.#{ENV['TRAVIS_JOB_NUMBER']}"
  end
end
