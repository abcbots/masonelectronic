# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'makena/version'

Gem::Specification.new do |spec|
  spec.name          = "makena"
  spec.version       = Makena::VERSION
  spec.authors       = ["makenabots"]
  spec.email         = ["davemakena@gmail.com"]
  spec.summary       = "A collection of standard MAKENABots Mobile App methods."
  spec.description   = "A collection of methods that make a standard MAKENABots Mobile App work."
  spec.homepage      = "http://www.MAKENABOTS.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
