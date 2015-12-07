source 'https://rubygems.org'

gem "jruby-openssl", :platforms => :jruby
gem "mime-types", "~> 2.99", :platforms => :ruby_19

group :test do
  gem "simplecov"
  gem "byebug", :platform => [:ruby_20, :ruby_21]

  # only used for uploads testing
  gem "actionpack", "~> 3.2"
end

gemspec
