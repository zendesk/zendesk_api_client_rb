require 'rake/testtask'
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'rubocop/rake_task'

begin
  require 'rspec/core/rake_task'
rescue LoadError
end

if defined?(RSpec)
  desc "Run specs"
  RSpec::Core::RakeTask.new("spec") do |t|
    t.pattern = "spec/core/**/*_spec.rb"
  end

  desc "Run live specs"
  RSpec::Core::RakeTask.new("spec:live") do |t|
    t.pattern = "spec/live/**/*_spec.rb"
  end

  task :clean_live do
    sh "rm -rf spec/fixtures/cassettes"
  end

  task :set_ci_credentials do
    File.open("spec/fixtures/credentials.yml", "w") do |f|
      f.write(
        File.read("spec/fixtures/credentials.yml.example")
          .sub("your_username", ENV.fetch("SPEC_LIVE_USERNAME"))
          .sub("your_password", ENV.fetch("SPEC_LIVE_PASSWORD"))
          .sub("your_zendesk_host", ENV.fetch("SPEC_LIVE_ZENDESK_HOST"))
        )
    end
  end

  if RUBY_VERSION =~ /1.9/
    desc "Find coverage"
    task "spec:coverage" do
      ENV["COVERAGE"] = "yes"
      Rake::Task["spec"].invoke
    end
  end

  desc 'Default: run specs.'
  task :default => "spec"
end

# extracted from https://github.com/grosser/project_template
rule(/^version:bump:.*/) do |t|
  sh "git status | grep 'nothing to commit'" # ensure we are not dirty
  index = %w(major minor patch).index(t.name.split(':').last)
  file = 'lib/zendesk_api/version.rb'

  version_file = File.read(file)
  old_version, *version_parts = version_file.match(/(\d+)\.(\d+)\.(\d+)/).to_a
  version_parts[index] = version_parts[index].to_i + 1
  version_parts[2] = 0 if index < 2 # remove patch for minor
  version_parts[1] = 0 if index < 1 # remove minor for major
  new_version = version_parts * '.'
  File.open(file, 'w') { |f| f.write(version_file.sub(old_version, new_version)) }

  sh "bundle && git add #{file} Gemfile.lock && git commit -m 'bump version to #{new_version}'"
end
