source 'https://rubygems.org'

gem "jruby-openssl", platforms: :jruby
gem "mini_mime"
gem "rake"
gem "addressable", ">= 2.8.0"
gem "yard"
gem "json", ">= 2.3.0", platforms: :ruby
gem "scrub_rb"

gem "rubocop", "~> 0.64.0", require: false

group :test do
  gem "webmock"
  gem "vcr", "~> 6.0"
  gem "rspec"

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
