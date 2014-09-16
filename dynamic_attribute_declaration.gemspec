# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamic_attribute_declaration/version'

Gem::Specification.new do |spec|
  spec.name          = "dynamic_attribute_declaration"
  spec.version       = DynamicAttributeDeclaration::VERSION
  spec.authors       = ["Mikkel Wied Frederiksen"]
  spec.email         = ["mikkel@wied.cc"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency('database_cleaner')

  spec.add_dependency "activerecord", "~> 4.0"
  spec.add_dependency "activesupport", "~> 4.0"
end
