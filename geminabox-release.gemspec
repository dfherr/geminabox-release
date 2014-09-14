# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'geminabox-release/version'

Gem::Specification.new do |spec|
  spec.name          = "geminabox-release"
  spec.version       = GeminaboxRelease::VERSION
  spec.authors       = ["Dennis-Florian Herr"]
  spec.email         = ["dennis.herr@experteer.com"]
  spec.description   = 'Dependency free rake release task for geminabox'
  spec.summary       = 'see readme'
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"]
  spec.files        += [".gitignore", ".ruby-version", "Gemfile", "geminabox-release.gemspec", "README.md", "Rakefile", "LICENSE"]
  spec.require_paths = ["lib"]

end


