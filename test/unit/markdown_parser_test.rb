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

      def test_multiple_blocks
        expected = <<~HTML.chomp
          <h1>Hello</h1><p>world, we <code>have</code> nested code spans.</p>
        HTML
        assert_rendered(<<~MARKDOWN, expected)
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

      def test_fenced_code_block
        assert_rendered(<<~MARKDOWN, "<pre><code></code></pre>")
          ```
          ```
        MARKDOWN
        assert_rendered(<<~MARKDOWN, "<pre><code>aaa\nbbb</code></pre>")
          ```
          aaa
          bbb
          ```
        MARKDOWN
      end

      def test_fenced_code_block_with_indentation
        assert_rendered(<<~MARKDOWN, "<pre><code>aaa\nbbb</code></pre>")
           ```
           aaa
          bbb
          ```
        MARKDOWN
      end

      def test_fenced_code_block_with_multiple_instances_of_indentation
        assert_rendered(<<~MARKDOWN, "<pre><code>aaa\nbbb\nccc</code></pre>")
            ```
          aaa
            bbb
          ccc
            ```
        MARKDOWN
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

      def test_lists
        assert_rendered(
          <<~MARKDOWN,
            - one
            - two
          MARKDOWN
          <<~HTML.chomp,
            <ul>
            <li>one</li>
            <li>two</li>
            </ul>
          HTML
        )
      end

      def test_lists_with_inline_markup
        assert_rendered(
          <<~MARKDOWN,
            - *one*
            - **two**
          MARKDOWN
          <<~HTML.chomp,
            <ul>
            <li><em>one</em></li>
            <li><strong>two</strong></li>
            </ul>
          HTML
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
