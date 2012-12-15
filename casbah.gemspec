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

  gem.add_dependency 'rails', '~> 3.2.9'
  # gem.add_dependency 'jquery-rails'

  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'rspec-rails', '~> 2.12.0'
end
