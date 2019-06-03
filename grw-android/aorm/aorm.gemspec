# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aorm/version'

Gem::Specification.new do |spec|
  spec.name          = "aorm"
  spec.version       = Aorm::VERSION
  spec.authors       = ["Grzegorz Daniluk"]
  spec.email         = ["gdaniluk@gmail.com"]
  spec.summary       = %q{grw Android ORM.}
  spec.description   = %q{Code generation tool.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>=2.1.1'

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
