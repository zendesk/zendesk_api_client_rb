require 'rake/testtask'
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new("spec") do |t|
  t.pattern = "spec/core/**/*_spec.rb"
end

desc "Run live specs"
RSpec::Core::RakeTask.new("spec:live") do |t|
  t.pattern = "spec/live/**/*_spec.rb"
end

desc 'Default: run specs.'
task :default => :spec
