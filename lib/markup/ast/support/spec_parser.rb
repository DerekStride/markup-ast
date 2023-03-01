# frozen_string_literal: true

module Markup
  module Ast
    class SpecParser
      def initialize(io)
        @io = io
        @specs = []
        next_line
      end

      def parse
        until eof?
          expect_peek(/^===+$/)
          name = next_line.gsub(%r{[-.:/# ]}, "_")
          expect_peek(/^===+$/)
          markdown = +""
          markdown << next_line << "\n" until peek.match?(/^---+$/)
          expect_peek(/^---+$/)
          sexpr = +""
          sexpr << next_line << "\n" until eof? || peek.match?(/^===+$/)

          @specs << {
            name:,
            markdown:,
            # sexpr: sexpr,
          }
        end

        @specs
      end

      private

      attr_reader :peek

      def next_line
        return :eof if eof?

        curr = peek
        @peek = @io.gets&.chomp || :eof
        curr
      end

      def expect_peek(regex)
        raise("Expected #{regex.inspect} but got #{peek.inspect}") unless peek.match?(regex)

        next_line
      end

      def eof? = peek == :eof
    end
  end
end
