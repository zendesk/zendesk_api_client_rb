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
  s.license     = 'Apache-2.0'

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/zendesk/zendesk_api_client_rb/issues',
    'changelog_uri' => "https://github.com/zendesk/zendesk_api_client_rb/blob/v#{s.version}/CHANGELOG.md",
    'documentation_uri' => "https://www.rubydoc.info/gems/zendesk_api/#{s.version}",
    'source_code_uri' => "https://github.com/zendesk/zendesk_api_client_rb/tree/v#{s.version}",
    'wiki_uri' => 'https://github.com/zendesk/zendesk_api_client_rb/wiki'
  }

  s.files = Dir.glob('{lib,util}/**/*') << 'LICENSE'

  s.required_ruby_version     = ">= 2.3"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency "faraday", ">= 0.9.0", "< 2.0.0"
  s.add_runtime_dependency "hashie", ">= 3.5.2", "< 5.0.0"
  s.add_runtime_dependency "inflection"
  s.add_runtime_dependency "multipart-post", "~> 2.0"
  s.add_runtime_dependency "mini_mime"
end
