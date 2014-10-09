# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamic_attribute_declaration/version'

Gem::Specification.new do |spec|
  spec.name          = "dynamic_attribute_declaration"
  spec.version       = DynamicAttributeDeclaration::VERSION
  spec.authors       = ["Mikkel Wied Frederiksen"]
  spec.email         = ["mikkel@wied.cc"]
  spec.summary       = %q{This gem lets you dynamically declare validations, that can function as partly applied validation, based on some kind of model instance state.}
  spec.description   = %q{DESCRIPTION ON THE WAY! :)}
  spec.homepage      = "https://github.com/mikkelwf/dynamic_attribute_declaration"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "guard-rspec", "~> 4.2"
  spec.add_development_dependency "rspec-its", "~> 1"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "database_cleaner", "~> 1.3"

  spec.add_dependency "activerecord", "~> 4.0"
  spec.add_dependency "activesupport", "~> 4.0"
end
