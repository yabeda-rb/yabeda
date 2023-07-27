# frozen_string_literal: true

require "forwardable"
require_relative "group"

module Yabeda
  # Represents implicit global group
  class GlobalGroup < Group
    extend Forwardable

    def_delegators ::Yabeda, :default_tags, :default_tag
  end
end
