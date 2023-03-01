# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/ast/support/**/*.rb")
loader.ignore("#{__dir__}/ast/support.rb")
loader.setup

module Markup
  module Ast
    class Error < StandardError; end
  end
end
