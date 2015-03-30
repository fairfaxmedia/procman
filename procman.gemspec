# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'procman/version'

Gem::Specification.new do |spec|
  spec.name          = "procman"
  spec.version       = Procman::VERSION
  spec.authors       = ["Michael Lorant"]
  spec.email         = ["michael.lorant@fairfaxmedia.com.au"]

  spec.summary       = %q{Installs Foreman procfile using an RVM aware template.}
  spec.description   = %q{Installs Foreman procfile using an RVM aware template.}
  spec.homepage      = "http://bitbucket.org/fairfax"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["bin"]

  spec.add_runtime_dependency "foreman", "~> 0.78"
  spec.add_runtime_dependency "mixlib-cli", "~> 1.5"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "gemfury", "~> 0.4"
  spec.add_development_dependency "rubocop", "~> 0.29"
end
