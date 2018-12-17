# frozen_string_literal: true

require "yabeda/dsl/class_methods"

module Yabeda
  # DSL for ease of work with Yabeda
  module DSL
    def self.included(base)
      base.extend DSL::ClassMethods
    end
  end
end
