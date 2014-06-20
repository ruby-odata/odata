# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'odata/version'

Gem::Specification.new do |spec|
  spec.name          = 'odata'
  spec.version       = OData::VERSION
  spec.authors       = ['James Thompson']
  spec.email         = %w{james@plainprograms.com}
  spec.summary       = %q{Simple OData library}
  spec.description   = %q{Provides a simple interface for working with OData APIs.}
  spec.homepage      = 'https://github.com/plainprogrammer/odata'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w{lib}

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov', '~> 0.8.2'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'webmock', '~> 1.18.0'

  spec.add_dependency 'nokogiri', '~> 1.6.2'
  spec.add_dependency 'activesupport', '>= 3.0.0'
  spec.add_dependency 'typhoeus', '~> 0.6.8'
end
