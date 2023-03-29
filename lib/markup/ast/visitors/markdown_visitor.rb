# frozen_string_literal: true

module Markup
  module Ast
    module Visitors
      class MarkdownVisitor < TreeStand::Visitor
        attr_reader :stack

        def initialize(node, inline_parser)
          super(node)
          @inline_parser = inline_parser
          @stack = []
        end

        def on_inline(node)
          tree = @inline_parser.parse_string(node.text)

          if tree.root_node.any?
            visitor = Visitors::InlineVisitor.new(tree.root_node).visit
            @stack.last.children.concat(visitor.stack)
          else
            @stack.last.children << Text.new(node.text.strip)
          end
        end

        def on_paragraph(node)
          @stack.push(Paragraph.new(node))
        end

        def on_atx_heading(node)
          @stack.push(Heading.new(node))
        end

        def on_atx_h1_marker(*) = @stack.last.level = 1
        def on_atx_h2_marker(*) = @stack.last.level = 2
        def on_atx_h3_marker(*) = @stack.last.level = 3
        def on_atx_h4_marker(*) = @stack.last.level = 4
        def on_atx_h5_marker(*) = @stack.last.level = 5
        def on_atx_h6_marker(*) = @stack.last.level = 6
      end
    end
  end
end
