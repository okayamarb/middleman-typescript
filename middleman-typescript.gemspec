# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-typescript/version'

Gem::Specification.new do |spec|
  spec.name          = "middleman-typescript"
  spec.version       = Middleman::Typescript::VERSION
  spec.authors       = ["Toyoaki Oko"]
  spec.email         = ["chariderpato@gmail.com"]
  spec.summary       = %q{TypeScript support for middleman}
  spec.description   = %q{TypeScript support for middleman}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency("middleman-core", ["~> 3.2"])
  spec.add_dependency("typescript-node", ["~> 1.1"])
end
