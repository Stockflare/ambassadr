# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ambassadr/version'

Gem::Specification.new do |spec|
  spec.name          = "ambassadr"
  spec.version       = Ambassadr::VERSION
  spec.authors       = ["davidkelley"]
  spec.email         = ["david.james.kelley@gmail.com"]
  spec.summary       = %q{Publishes and maintains micro-service endpoints to etcd.}
  spec.homepage      = "https://github.com/bruw/ambassadr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'faraday'
  spec.add_dependency 'etcd'
  spec.add_dependency 'docker-api'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'yard'

end
