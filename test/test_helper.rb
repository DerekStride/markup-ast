# frozen_string_literal: true

require "bundler/setup"
require "markup/ast"

require "pry-byebug"
require "minitest/autorun"
require "minitest/excludes"
require "minitest/focus"
require "minitest/reporters"

Minitest::Reporters.use!

module MarkdownHelper
  def render(markdown)
    <<~HTML
      <!DOCTYPE html>
    HTML
  end
end

module SpecHelper
  module ClassMethods
    def run(*args)
      super
      return unless ENV["UPDATE_SPECS"]

      failed_specs.sort.each do |name|
        excluded_spec_file.puts "exclude :#{name}, \"failed\""
      end
      excluded_spec_file.close
    end

    def failed_specs
      @failed_specs ||= []
    end

    def excluded_spec_file
      @excluded_spec_file ||= File.open(File.join(__dir__, "excludes", "GeneratedSpecTest.rb"), "a")
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    return unless ENV["UPDATE_SPECS"]

    base.excluded_spec_file.truncate(0)
  end

  def teardown
    self.class.failed_specs << name unless passed?
  end
end
