source 'https://rubygems.org'

gem "simplecov", :platforms => :ruby_19, :group => :test
gem "jruby-openssl", :platforms => :jruby
gem "mime-types", "~> 2.99", :platforms => :ruby_19

group :test do
  gem "byebug", :platform => [:ruby_20, :ruby_21]
  gem "json", :platform => :ruby_18

  # only used for uploads testing
  gem "actionpack", "~> 3.2"
end

gemspec
