# frozen_string_literal: true

require "erb"
require "fileutils"
require "markup/ast/support"
require "webmock"

include WebMock::API # rubocop:disable Style/MixinUsage

namespace :specs do
  task :generate do
    specs = Dir["spec/*.txt"].flat_map do |file|
      Markup::Ast::SpecParser.new(File.open(file)).parse
    end

    WebMock.enable!

    specs.each do |h|
      VCR.use_cassette(h[:name]) do
        h[:html] = Octokit.markdown(h[:markdown], mode: :gfm)
      end
    end

    template = ERB.new(File.read(File.join(__dir__, "..", "templates", "spec_test.rb.erb")))

    content = Markup::Ast::SpecGenerator.new(specs).generate!(template)

    File.write(
      File.join(__dir__, "..", "test", "spec", "generated_spec_test.rb"),
      content,
    )
  end
end
