require 'rake/testtask'
require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
rescue LoadError
end

if defined?(RSpec)
  desc "Run specs"
  RSpec::Core::RakeTask.new(:spec)

  desc "Run live specs"
  RSpec::Core::RakeTask.new("spec:live") do |t|
    t.pattern = "live/*_spec.rb"
  end

  task :clean_live do
    sh "rm -rf spec/fixtures/cassettes"
  end

  if RUBY_VERSION =~ /1.9/
    desc "Find coverage"
    task "spec:coverage" do
      ENV["COVERAGE"] = "yes"
      Rake::Task["spec"].invoke
    end
  end

  desc 'Default: run specs.'
  task :default => :spec
end

desc "Run irb with zendesk client lib loaded"
task :console do
  sh "bundle exec irb -I lib -r ./lib/zendesk.rb"
end

