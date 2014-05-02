source 'https://rubygems.org'

# gem "bundler", "~> 1.2.0"
# ruby "1.9.3"

gem "simplecov", :platforms => :ruby_19, :group => :test
gem "jruby-openssl", :platforms => :jruby

group :console do
  gem "ripl"
end

group :test do
  gem "json", :platform => :ruby_18

  # only used for uploads testing
  gem "actionpack", "~> 3.2"
end

gemspec
