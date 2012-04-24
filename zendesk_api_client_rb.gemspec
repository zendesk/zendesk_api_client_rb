# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'zendesk/version'

Gem::Specification.new do |s|
  s.name        = "zendesk"
  s.version     = Zendesk::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [""]
  s.email       = ["sdavidovitz@zendesk.com"]
  s.homepage    = "http://zendesk.com"
  s.summary     = %q{}
  s.description = %q{}

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"

  s.add_runtime_dependency "faraday", ">= 0.8.0"
  s.add_runtime_dependency "faraday_middleware", ">= 0.8.7"
  s.add_runtime_dependency "hashie"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "inflection"

  s.files              = `git ls-files`.split("\n") rescue ''
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = []
  s.require_paths      = ["lib"]
end
