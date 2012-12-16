# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'casbah/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name          = 'casbah'
  gem.version       = Casbah::VERSION
  gem.authors       = ['Derek Lindahl']
  gem.email         = ['dlindahl@customink.com']
  gem.homepage      = 'https://github.com/dlindahl/casbah'
  gem.description   = 'A CAS server Rails engine'
  gem.summary       = gem.description

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'rails',       '~> 3.2.9'
  gem.add_dependency 'redis',       '~> 3.0.2'
  gem.add_dependency 'addressable', '~> 2.3.2'
  gem.add_dependency 'warden',      '~> 1.2.1'

  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'rspec-rails', '~> 2.12.0'
  gem.add_development_dependency 'mock_redis',  '~> 0.6.2'
  gem.add_development_dependency 'nokogiri',    '~> 1.5.5'
end
