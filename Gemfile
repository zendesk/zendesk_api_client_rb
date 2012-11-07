source 'https://rubygems.org'

gem "simplecov", :platforms => :ruby_19, :group => :development
gem "jruby-openssl", :platforms => :jruby
gem "hashie", :git => "git://github.com/intridea/hashie.git"
gem "multipart-post", :git => "git://github.com/steved555/multipart-post.git"

group :server do
  gem "rack-secure_only"

  gem "sinatra"
  gem "sinatra-contrib"

  gem "haml"

  gem "compass"
  gem "bootstrap-sass"

  gem "coderay"
  gem "coderay_bash"

  gem "redcarpet"
end

group :console do
  gem "ripl"
end

gemspec
