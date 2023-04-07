# frozen_string_literal: true

require "tree_stand"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.tag = File.basename(__FILE__, ".rb")
loader.inflector = Zeitwerk::GemInflector.new(__FILE__)

loader.push_dir(File.join(__dir__, ".."))
loader.ignore("#{__dir__}/ast/support/**/*.rb")
loader.ignore("#{__dir__}/ast/support.rb")
loader.setup

module Markup
  module Ast
    class Error < StandardError; end

    class Node
      attr_accessor :content_start
      attr_reader :root, :children

      def initialize(root)
        @root = root
        @children = []
        @content_start = root.range.start_byte
      end

      def to_html = "<#{tag}>#{children.map(&:to_html).join}</#{tag}>"
      def tag = raise NotImplementedError
    end

    Text = Data.define(:text) do
      def to_html = text.chomp
    end

    class Document < Node
      def to_html = children.map(&:to_html).join
    end

    class Section < Node
      def to_html = children.map(&:to_html).join
    end

    class Heading < Node
      attr_accessor :level

      def tag = "h#{@level}"
    end

    class Paragraph < Node
      def tag = "p"
    end

    class Pre < Node
      def tag = "pre"
    end

    class UnorderedList < Node
      def to_html = "<ul>\n#{children.map(&:to_html).join}</ul>"
    end

    class ListItem < Node
      def tag = "li"
      def to_html = "#{super}\n"
    end

    class InlineNode < Node
      attr_reader :delimiters

      def initialize(root, inline_root)
        super(root)
        @inline_root = inline_root
        @delimiters = []
      end

      def delimit(node, parent_ast_node)
        @delimiters << node

        self.content_start = node.range.end_byte if @delimiters.size == inner_delimiter_start

        if @delimiters.size == 1
          document_range = parent_ast_node.content_start...(@inline_root.range.start_byte + node.range.start_byte)
          parent_ast_node.children << Text.new(parent_ast_node.root.tree.document[document_range])
        end

        if @delimiters.size == inner_delimiter_end
          children << Text.new(node.tree.document[content_start...node.range.start_byte])
        end

        return unless @delimiters.size == delimiter_count

        parent_ast_node.content_start = @inline_root.range.start_byte + node.range.end_byte
        :pop
      end

      def delimiter_count = raise NotImplementedError
      def inner_delimiter_start = delimiter_count / 2
      def inner_delimiter_end = inner_delimiter_start + 1
    end

    class Strong < InlineNode
      def tag = "strong"
      def delimiter_count = 4
    end

    class Emphasis < InlineNode
      def tag = "em"
      def delimiter_count = 2
    end

    class CodeSpan < InlineNode
      def tag = "code"
      def delimiter_count = 2
    end
  end
end
