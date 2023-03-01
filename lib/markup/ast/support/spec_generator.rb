# frozen_string_literal: true

module Markup
  module Ast
    SpecGenerator = Struct.new(:specs) do
      def generate!(template) = template.result(binding)
    end
  end
end
