# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in yabeda.gemspec
gemspec

group :development, :test do
  gem "pry"
  gem "pry-byebug", platform: :mri

  gem "rubocop"
  gem "rubocop-rspec"
end
