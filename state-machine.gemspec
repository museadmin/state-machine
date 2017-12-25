# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'state/machine/version'

Gem::Specification.new do |spec|
  spec.name          = 'state-machine'
  spec.version       = State::Machine::VERSION
  spec.authors       = ['Bradley Atkins']
  spec.email         = ['bradley.atkinz@gmail.com']

  spec.summary       = 'A customisable state machine'
  spec.description   = 'A customisable state machine in the form of a gem'
  spec.homepage      = 'https://github.com/museadmin/state-machine'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://localhost:9292/'
  else
    raise 'RubyGems 2.0 or newer required to protect against public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0")
                                .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'bundler', '1.16.0'
  spec.add_runtime_dependency 'facets', '3.1.0'
  spec.add_runtime_dependency 'minitest', '5.10.1'
  spec.add_runtime_dependency 'rake', '~> 0'
  spec.add_runtime_dependency 'sqlite3', '1.3.13'
end
