# frozen_string_literal: true

require "anyway"

module Yabeda
  # Runtime configuration for the main yabeda gem
  class Config < ::Anyway::Config
    config_name :yabeda

    # Declare and collect metrics about Yabeda performance
    attr_config debug: false
  end
end
