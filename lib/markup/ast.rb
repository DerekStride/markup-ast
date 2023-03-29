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
      attr_reader :root, :children

      def initialize(root)
        @root = root
        @children = []
      end

      def to_html = "<#{tag}>#{children.map(&:to_html).join}</#{tag}>"
      def tag = raise NotImplementedError
    end

    Text = Struct.new(:to_html)

    class Heading < Node
      attr_accessor :level

      def tag = "h#{@level}"
    end

    class Paragraph < Node
      def tag = "p"
    end

    class InlineNode < Node
      attr_accessor :content_start
      attr_reader :delimiters

      def initialize(root)
        super(root)
        @delimiters = []
      end

      def delimit(node, parent)
        @delimiters << node

        self.content_start = node.range.end_byte if @delimiters.size == inner_delimiter_start

        if @delimiters.size == 1 && parent
          parent.children << Text.new(node.tree.document[parent.content_start...node.range.start_byte])
        end

        if @delimiters.size == inner_delimiter_end
          children << Text.new(node.tree.document[content_start...node.range.start_byte])
        end

        return unless @delimiters.size == delimiter_count

        parent.content_start = node.range.end_byte if parent
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
