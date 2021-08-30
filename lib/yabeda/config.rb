# frozen_string_literal: true

require "anyway"

module Yabeda
  # Runtime configuration for the main yabeda gem
  class Config < ::Anyway::Config
    config_name :yabeda

    # Declare and collect metrics about Yabeda performance
    attr_config debug: false

    # Implement predicate method from AnywayConfig 2.x to support AnywayConfig 1.x users
    alias debug? debug unless instance_methods.include?(:debug?)
  end
end
