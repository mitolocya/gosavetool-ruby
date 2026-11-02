# frozen_string_literal: true

require_relative "lib/gosavetool/version"

Gem::Specification.new do |spec|
  spec.name = "gosavetool"
  spec.version = GoSaveTool::VERSION
  spec.authors = ["GoSaveTool"]
  spec.summary = "SRT and WebVTT subtitle tools, word count, social media limits and case changes"
  spec.description = "Parse, convert, shift and repair SRT and WebVTT subtitles; word, character and reading-time " \
                     "counts, social media character limits, Title Case, slugs and other case changes. " \
                     "No dependencies, with a command-line tool."
  spec.homepage = "https://www.gosavetool.com/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata = {
    "homepage_uri" => "https://www.gosavetool.com/",
    "source_code_uri" => "https://github.com/mitolocya/gosavetool-ruby",
    "bug_tracker_uri" => "https://www.gosavetool.com/contact",
    "changelog_uri" => "https://github.com/mitolocya/gosavetool-ruby/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["lib/**/*.rb", "exe/*", "README.md", "LICENSE.txt", "CHANGELOG.md"]
  spec.bindir = "exe"
  spec.executables = ["gosavetool"]
  spec.require_paths = ["lib"]
end
