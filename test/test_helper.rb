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
    def excluded_spec_file
      @excluded_spec_file ||= begin
        f = File.open(
          File.join(__dir__, "excludes", "GeneratedSpecTest.rb"),
          "a",
        )
        f.sync = true
        f.truncate(0)
        f
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def teardown
    return unless ENV["UPDATE_SPECS"]
    return if passed?

    self.class.excluded_spec_file.puts "exclude :#{name}, \"failed\""
  end
end
