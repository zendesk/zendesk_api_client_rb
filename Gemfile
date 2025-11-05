source "https://rubygems.org"

gem "jruby-openssl", platforms: :jruby
gem "mini_mime"
gem "rake"
gem "addressable", ">= 2.8.0"
gem "yard"
gem "json", ">= 2.3.0", platforms: :ruby
gem "scrub_rb"

gem "standard"

group :test do
  gem "webmock"
  gem "vcr", "~> 6.0"

  # Hardcoding these gems as the newer version makes the tests fail in Ruby 3
  # See https://github.com/zendesk/zendesk_api_client_rb/runs/5013748785?check_suite_focus=true#step:4:59
  # NOTE: This affects previous build re-runs because we don't store Gemfile.lock
  gem "rspec-support", "3.10.3"
  gem "rspec-core", "3.10.1"
  gem "rspec-expectations", "3.10.2"
  gem "rspec-mocks", "3.10.2"
  gem "rspec", "3.10.0"

  # only used for uploads testing
  gem "actionpack", ">= 5.2.4.6"
end

group :dev do
  gem "bump"
end

group :dev, :test do
  gem "byebug", platforms: :ruby
end

gemspec
