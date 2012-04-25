require 'rake/testtask'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new

if RUBY_VERSION =~ /1.9/
  desc "Find coverage"
  task "spec:coverage" do
    ENV["COVERAGE"] = "yes" 
    Rake::Task["spec"].invoke
  end
end

desc "Run irb with zendesk client lib loaded"
task :console do
  sh "bundle exec irb -I lib -r ./lib/zendesk_console.rb"
end

desc 'Default: run specs.'
task :default => :spec
