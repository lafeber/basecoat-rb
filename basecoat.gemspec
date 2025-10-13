# frozen_string_literal: true

require_relative "lib/basecoat/version"

Gem::Specification.new do |spec|
  spec.name = "basecoat"
  spec.version = Basecoat::VERSION
  spec.authors = ["Martijn Lafeber"]
  spec.email = ["lafeber@gmail.com"]

  spec.summary = "Rails scaffold templates and Devise views styled with Basecoat CSS"
  spec.description = "Provides beautiful, production-ready scaffold templates and Devise views styled with Basecoat CSS framework"
  spec.homepage = "https://github.com/yourusername/basecoat"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yourusername/basecoat"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "tailwindcss-rails", "~> 4.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
