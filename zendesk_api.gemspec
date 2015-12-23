lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'zendesk_api/version'

Gem::Specification.new do |s|
  s.name        = 'zendesk_api'
  s.version     = ZendeskAPI::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Steven Davidovitz', 'Michael Grosser']
  s.email       = ['support@zendesk.com']
  s.homepage    = 'http://developer.zendesk.com'
  s.summary     = %q{Zendesk REST API Client}
  s.description = %q{Ruby wrapper for the REST API at http://www.zendesk.com. Documentation at http://developer.zendesk.com.}
  s.license     = 'Apache License Version 2.0'

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency 'bump'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'vcr', '~> 3.0'
  s.add_development_dependency 'multi_json' # For VCR's JSON format
  s.add_development_dependency 'webmock', '~> 1.22'
  s.add_development_dependency 'yard', '~> 0.8'

  s.add_runtime_dependency 'faraday', '~> 0.9'
  s.add_runtime_dependency 'faraday_middleware', '~> 0.10'
  s.add_runtime_dependency 'faraday-http-cache', '~> 1.2'
  s.add_runtime_dependency 'hashie', '>= 1.2', '< 4.0'
  s.add_runtime_dependency 'mime-types', '~> 3.0'

  s.files = Dir.glob('lib/**/*')
end
