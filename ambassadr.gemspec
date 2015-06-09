# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ambassadr/version'

Gem::Specification.new do |spec|
  spec.name          = "ambassadr"
  spec.version       = Ambassadr::VERSION
  spec.date          = `git log --pretty="%ai" -n 1`.split(" ").first
  spec.authors       = ["David Kelley"]
  spec.email         = ["david.james.kelley@gmail.com"]
  spec.summary       = %q{Publishes and maintains micro-service endpoints to etcd.}
  spec.description   = %q{Uses Docker and Etcd to publish and heartbeat micro-service API Endpoints to facilitate service discovery and programmatic usage.}
  spec.homepage      = "https://github.com/bruw/ambassadr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["ambassador"]
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0.0")

  spec.add_runtime_dependency %q<activesupport>, ['~> 4.2']
  spec.add_runtime_dependency %q<faraday>, ['~> 0.9']
  spec.add_runtime_dependency %q<etcd>, ['~> 0.3']
  spec.add_runtime_dependency %q<docker-api>, ['~> 1.21']

  spec.add_development_dependency %q<bundler>, ['~> 1.6']
  spec.add_development_dependency %q<rake>, ['~> 10.3']
  spec.add_development_dependency %q<rspec>, ['~> 3.0']
  spec.add_development_dependency %q<faker>, ['~> 1.4']
  spec.add_development_dependency %q<yard>, ['~> 0.8']
  spec.add_development_dependency %q<dotenv>, ['~> 2.0']

end
