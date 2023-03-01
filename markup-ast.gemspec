# frozen_string_literal: true

require_relative "lib/markup/ast/version"

Gem::Specification.new do |spec|
  spec.name = "markup-ast"
  spec.version = Markup::Ast::VERSION
  spec.authors = ["derekstride"]
  spec.email = ["derek@stride.host"]

  spec.summary = "A Markdown to HTML converter powered by the tree-sitter-markdown grammar."
  spec.description = spec.summary
  spec.homepage = "https://github.com/derekstride/ts-markdown"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => spec.homepage,
    "rubygems_mfa_required" => "true",
  }

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby_tree_sitter"
  spec.add_dependency "tree_stand"
  spec.add_dependency "zeitwerk"
end
