# frozen_string_literal: true

require "bundler/setup"

require "debug"
require "minitest/autorun"
require "minitest/excludes"
require "minitest/focus"
require "minitest/reporters"

require "markup/ast"

Minitest::Reporters.use!

TreeStand.configure do
  config.parser_path = File.join(__dir__, "..", "treesitter")
end

module MarkdownHelper
  def setup
    @parser = Markup::Ast::MarkdownParser.new
  end

  def render(markdown)
    "#{@parser.parse(markdown).to_html}\n"
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
