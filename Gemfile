source 'https://rubygems.org'

gem "jruby-openssl", :platforms => :jruby
gem "mini_mime"
gem "rake"
gem "addressable", "< 2.5.0", :platforms => [:ruby_19, :jruby]
gem "yard"
gem "json", ">= 2.3.0", :platforms => :ruby_19
gem "scrub_rb", :platforms => [:ruby_19, :ruby_20, :jruby]

gem "rubocop", "~> 0.64.0", :require => false

group :test do
  gem "simplecov"
  gem "byebug", :platform => [:ruby_20, :ruby_21]
  gem "webmock"
  gem "vcr"
  gem "rspec"

  # only used for uploads testing
  gem "actionpack", "~> 3.2"
end

group :dev do
  gem "bump"
end

gemspec
