# frozen_string_literal: true

require "fileutils"

namespace :treesitter do
  task :install do
    app_root = File.expand_path("..", __dir__)
    tmp_dir = File.join(app_root, "tmp")

    repo_url = "https://github.com/MDeiml/tree-sitter-markdown.git"
    repo_sha = "7e7aa9a25ca9729db9fe22912f8f47bdb403a979"
    repo_dir = "tree-sitter-markdown-#{repo_sha}".freeze

    parser_md_so = File.join(tmp_dir, repo_dir, "tree-sitter-markdown", "parser.so")
    target_md = File.join(app_root, "treesitter", "markdown.so")

    parser_inline_so = File.join(tmp_dir, repo_dir, "tree-sitter-markdown-inline", "parser.so")
    target_inline = File.join(app_root, "treesitter", "markdown_inline.so")

    next if [parser_md_so, target_md, parser_inline_so, target_inline].all? { |f| File.exist?(f) }

    FileUtils.chdir(app_root) do
      FileUtils.mkdir_p "tmp"
      FileUtils.mkdir_p "treesitter"
    end

    FileUtils.chdir(tmp_dir) do
      system! "git clone --depth=1 #{repo_url} #{repo_dir}" unless File.exist?(repo_dir)

      FileUtils.chdir(repo_dir) do
        system! "git fetch origin #{repo_sha}"
        system! "git checkout #{repo_sha}"

        compile_parser("tree-sitter-markdown", parser_md_so, target_md)
        compile_parser("tree-sitter-markdown-inline", parser_inline_so, target_inline)
      end
    end
  end
end

def compile_parser(dir, shared_object, target)
  return if File.exist?(shared_object) && File.exist?(target)

  puts "Compiling #{dir}"
  FileUtils.chdir(dir) do
    system! "cc -c -Os -std=c99 -fPIC -I./src -o parser.o src/parser.c"
    system! "cc -c -Os -std=c++14 -fPIC -I./src -o scanner.o src/scanner.cc"
    system! "cc parser.o scanner.o -o parser.so -shared -lstdc++"
  end

  puts "Copying parser.so to ./treesitter/#{File.basename(target)}"
  FileUtils.cp(shared_object, target)
end

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end
