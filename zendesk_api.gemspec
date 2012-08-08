# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'zendesk_api/version'

Gem::Specification.new do |s|
  s.name        = "zendesk_api"
  s.version     = ZendeskAPI::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steven Davidovitz"]
  s.email       = ["sdavidovitz@zendesk.com"]
  s.homepage    = "http://developer.zendesk.com"
  s.summary     = %q{Zendesk REST API Client}
  s.description = %q{Ruby wrapper for the REST API at http://www.zendesk.com. Documentation at http://developer.zendesk.com.}
  s.license = 'MIT'

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "rspec", "~> 2.10.0"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
  s.add_development_dependency "rake"
  s.add_development_dependency "yard"

  s.add_runtime_dependency "faraday", ">= 0.8.0"
  s.add_runtime_dependency "faraday_middleware", ">= 0.8.7"
  s.add_runtime_dependency "hashie"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "inflection"
  s.add_runtime_dependency "mime-types"
  s.add_runtime_dependency "multipart-post"

  s.files              = `git ls-files -x Gemfile.lock`.split("\n") rescue ''
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths      = ["lib"]
end
