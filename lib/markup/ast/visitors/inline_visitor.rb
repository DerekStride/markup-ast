# frozen_string_literal: true

module Markup
  module Ast
    module Visitors
      class InlineVisitor < TreeStand::Visitor
        attr_reader :stack

        def initialize(root, inline_root, ast_node)
          super(root)
          @inline_root = inline_root
          @stack = [ast_node]
        end

        def around_inline(_)
          yield
          @stack.last.then do |ast_node|
            document_range = ast_node.content_start...ast_node.root.range.end_byte
            ast_node.children << Text.new(@inline_root.tree.document[document_range])
          end
        end

        def on_emphasis(node) = push_inline(Emphasis, node)
        def on_code_span(node) = push_inline(CodeSpan, node)
        def on_strong_emphasis(node) = push_inline(Strong, node)

        def on_emphasis_delimiter(node) = handle_delimiter(node)
        def on_code_span_delimiter(node) = handle_delimiter(node)

        private

        def push_inline(type, node)
          @stack << type.new(node, @inline_root)
        end

        def handle_delimiter(node)
          case @stack.last.delimit(node, @stack[-2])
          when :pop
            return unless @stack.size > 1

            @stack[-2].children << @stack.pop
          end
        end
      end
    end
  end
end
