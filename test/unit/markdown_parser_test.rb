# frozen_string_literal: true

require "test_helper"

module Markup
  module Ast
    class MarkdownParserTest < Minitest::Test
      def setup
        @parser = Markup::Ast::MarkdownParser.new
      end

      def test_parsing
        assert_kind_of(Markup::Ast::Node, @parser.parse("# Hello\n"))
      end

      def test_parsing_mixed_documents
        assert_kind_of(Markup::Ast::Node, @parser.parse(<<~MARKDOWN))
          # Hello

          world, we `have` nested code spans.
        MARKDOWN
      end

      def test_atx_heading
        [
          ["# Hello\n", "<h1>Hello</h1>"],
          ["## Hello\n", "<h2>Hello</h2>"],
          ["### Hello\n", "<h3>Hello</h3>"],
          ["#### Hello\n", "<h4>Hello</h4>"],
          ["##### Hello\n", "<h5>Hello</h5>"],
          ["###### Hello\n", "<h6>Hello</h6>"],
        ].each do |markdown, html|
          assert_rendered(markdown, html)
        end
      end

      def test_bold
        assert_rendered("**Hello**\n", "<p><strong>Hello</strong></p>")
      end

      def test_code
        assert_rendered("`Hello`\n", "<p><code>Hello</code></p>")
      end

      def test_emphasis
        assert_rendered("*Hello*\n", "<p><em>Hello</em></p>")
      end

      def test_combo
        assert_rendered(
          "**foo \"*bar*\" foo**\n",
          "<p><strong>foo \"<em>bar</em>\" foo</strong></p>",
        )
      end

      private

      def assert_rendered(markdown, html)
        document = @parser.parse(markdown)
        assert_equal(html, document.to_html)
      end
    end
  end
end
