# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twee2/version'

Gem::Specification.new do |spec|
  spec.name          = "twee2"
  spec.version       = Twee2::VERSION
  spec.authors       = ["Dan Q"]
  spec.email         = ["dan@danq.me"]
  spec.summary       = %q{Command-line tool to compile Twee-style (.tw, .twine) interactive fiction source files to Twine 2-style (non-Tiddlywiki) output.}
  spec.description   = <<-EOF
    Designed for those who preferred the Twee (for Twine 1) approach to source management, because the command-line is awesome,
    but who want to take advantage of the new features in Twine 2.
    Note that this is NOT a Twine 1 to Twine 2 converter, although parts of its functionality go some way to achieving this goal.
  EOF
  spec.homepage      = "https://github.com/avapoet/twee2"
  spec.license       = "GPL-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2'

  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'middleman', '>= 3.4.0'

  spec.add_runtime_dependency 'builder', '~> 3.2', '>= 3.2.2'
  spec.add_runtime_dependency 'bundler', '~> 1.6'
  spec.add_runtime_dependency 'coffee-script', '~> 2.4', '>= 2.4.1'
  spec.add_runtime_dependency 'coffee-script-source', '~> 1.9', '>= 1.9.1.1'
  spec.add_runtime_dependency 'execjs', '~> 2.6', '>= 2.6.0'
  spec.add_runtime_dependency 'filewatcher', '~> 0.5', '>= 0.5.2'
  spec.add_runtime_dependency 'haml', '~> 4.0', '>= 4.0.7'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.6.2'
  spec.add_runtime_dependency 'sass', '~> 3.2', '>= 3.2.19'
  spec.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.1'
  spec.add_runtime_dependency 'tilt', '~> 2.0', '>= 2.0.1'
  spec.add_runtime_dependency 'trollop', '~> 2.1', '>= 2.1.2'
end
