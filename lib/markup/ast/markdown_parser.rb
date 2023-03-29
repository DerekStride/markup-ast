# frozen_string_literal: true

module Markup
  module Ast
    class MarkdownParser
      def initialize
        @parser = TreeStand::Parser.new("markdown")
        @inline_parser = TreeStand::Parser.new("markdown_inline")
      end

      def parse(markdown)
        tree = @parser.parse_string(markdown)
        visitor = Visitors::MarkdownVisitor.new(tree.root_node, @inline_parser).visit
        visitor.stack.pop
      end
    end
  end
end
