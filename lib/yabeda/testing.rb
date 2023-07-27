# frozen_string_literal: true

# Include this file to get things prepared for testing

require_relative "test_adapter"

Yabeda.register_adapter(:test, Yabeda::TestAdapter.instance)
