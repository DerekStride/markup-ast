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
          Visitors::InlineVisitor.new(tree.root_node, node, @stack.last).visit
        end

        def around_document(node, &) = push_stack(Document.new(node), &)
        def around_section(node, &) = push_stack(Section.new(node), &)
        def around_paragraph(node, &) = push_stack(Paragraph.new(node), &)
        def around_atx_heading(node, &) = push_stack(Heading.new(node), &)
        def around_list(node, &) = push_stack(UnorderedList.new(node), &)

        def around_list_item(node)
          push_stack(ListItem.new(node)) do
            yield
            collapse_children!
          end
        end

        def around_fenced_code_block(node, &)
          @stack << Pre.new(node)
          push_stack(CodeSpan.new(node, node), &)
        end

        def on_code_fence_content(node)
          @stack.last.content_start = node.range.start_byte
        end

        def on_fenced_code_block_delimiter(node) = handle_delimiter(node)

        def on_atx_h1_marker(node) = handle_atx_marker(node, 1)
        def on_atx_h2_marker(node) = handle_atx_marker(node, 2)
        def on_atx_h3_marker(node) = handle_atx_marker(node, 3)
        def on_atx_h4_marker(node) = handle_atx_marker(node, 4)
        def on_atx_h5_marker(node) = handle_atx_marker(node, 5)
        def on_atx_h6_marker(node) = handle_atx_marker(node, 6)

        private

        def handle_atx_marker(node, level)
          @stack.last.then do |ast_node|
            ast_node.level = level
            ast_node.content_start = node.range.end_byte + 1
          end
        end

        def handle_delimiter(node)
          case @stack.last.delimit(node, @stack[-2])
          when :pop
            return unless @stack.size > 1

            @stack[-2].children << @stack.pop
          end
        end

        def collapse_children!
          @stack.last.children.map!(&:children)
          @stack.last.children.flatten!
        end

        def push_stack(ast_node)
          @stack << ast_node
          yield
          return if @stack.size == 1

          @stack[-2].children << @stack.pop
        end
      end
    end
  end
end
