# frozen_string_literal: true

module Markup
  module Ast
    module Visitors
      class InlineVisitor < TreeStand::Visitor
        attr_reader :stack

        def initialize(node)
          super(node)
          @stack = []
        end

        def on_emphasis(node) = @stack << Emphasis.new(node)
        def on_code_span(node) = @stack << CodeSpan.new(node)
        def on_strong_emphasis(node) = @stack << Strong.new(node)

        def on_emphasis_delimiter(node) = handle_delimiter(node)
        def on_code_span_delimiter(node) = handle_delimiter(node)

        private

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
