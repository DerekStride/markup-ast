# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "pry-byebug"
require "octokit"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.filter_sensitive_data("<GH_TOKEN>") { ENV.fetch("GH_TOKEN", nil) }
  config.hook_into :webmock
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.deps << "treesitter:install"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]
