# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinch/plugins/links-logger/version'

Gem::Specification.new do |gem|
  gem.name          = "cinch-links-logger"
  gem.version       = Cinch::Plugins::LinksLogger::VERSION
  gem.authors       = ["Brian Haberer"]
  gem.email         = ["bhaberer@gmail.com"]
  gem.description   = %q{Cinch Plugin to track links in the channel}
  gem.summary       = %q{Cinch Plugin for links logging}
  gem.homepage      = "https://github.com/bhaberer/cinch-links-logger"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'coveralls'
  gem.add_development_dependency 'cinch-test'

  gem.add_dependency 'cinch',           '~> 2.0.5'
  gem.add_dependency 'cinch-cooldown',  '~> 1.0.0'
  gem.add_dependency 'cinch-storage',   '~> 0.0.2'
  gem.add_dependency 'cinch-toolbox',   '~> 1.0.2'
  gem.add_dependency 'time-lord',       '~> 1.0.1'
end
