source 'https://rubygems.org'

gem "bundler", "~> 1.2.0"
ruby "1.9.3"

gem "simplecov", :platforms => :ruby_19, :group => :development
gem "jruby-openssl", :platforms => :jruby
gem "hashie", :git => "git://github.com/intridea/hashie.git"
gem "multipart-post", :git => "git://github.com/steved555/multipart-post.git"

group :server do
  gem "rack-ssl-enforcer"

  gem "sinatra"
  gem "sinatra-contrib"

  gem "haml"

  gem "compass"
  gem "bootstrap-sass"

  gem "coderay"
  gem "coderay_bash"

  gem "redcarpet"

  gem "mongoid"
  gem "database_cleaner"
end

group :console do
  gem "ripl"
end

gemspec
