source 'https://rubygems.org'

gem "jruby-openssl", :platforms => :jruby
gem "mime-types", "~> 2.99", :platforms => [:ruby_19, :jruby]
gem "bump"
gem "rake"
gem "rspec"
gem "rubocop", "0.39.0"
gem "vcr"
gem "webmock", "< 2"
gem "addressable", "< 2.5.0", :platforms => [:ruby_19, :jruby]
gem "yard"
gem "json", "< 2.0", :platforms => :ruby_19
gem "scrub_rb", :platforms => [:ruby_19, :ruby_20, :jruby]

group :test do
  gem "simplecov"
  gem "byebug", :platform => [:ruby_20, :ruby_21]

  # only used for uploads testing
  gem "actionpack", "~> 3.2"
end

gemspec
