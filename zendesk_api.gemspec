lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'zendesk_api/version'

Gem::Specification.new do |s|
  s.name        = "zendesk_api"
  s.version     = ZendeskAPI::VERSION
  s.authors     = ["Steven Davidovitz", "Michael Grosser"]
  s.email       = ["support@zendesk.com"]
  s.homepage    = "https://developer.zendesk.com"
  s.summary     = 'Zendesk REST API Client'
  s.description = 'Ruby wrapper for the REST API at https://www.zendesk.com. Documentation at https://developer.zendesk.com.'
  s.license     = 'Apache License Version 2.0'

  s.files = Dir.glob('{lib,util}/**/*')

  s.required_ruby_version     = ">= 1.9.0"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency "faraday", "~> 0.9"
  s.add_runtime_dependency "faraday_middleware", "~> 0.12.2"
  s.add_runtime_dependency "hashie", ">= 3.5.2", "< 4.0.0"
  s.add_runtime_dependency "inflection"
  s.add_runtime_dependency "multipart-post", "~> 2.0"
  s.add_runtime_dependency "mime-types"
end
