# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in yabeda.gemspec
gemspec

group :development, :test do
  gem "rake", "~> 12.0"
  gem "rspec", "~> 3.0"
  gem "yard"
  gem "yard-dry-initializer"

  gem "pry"
  gem "pry-byebug", platform: :mri

  gem "rubocop", "~> 1.0", require: false
  gem "rubocop-rspec", require: false
end
