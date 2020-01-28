# frozen_string_literal: true

module Yabeda
  class ConfigurationError < StandardError; end

  # Raises on repeated call to +Yabeda.configure!+
  class AlreadyConfiguredError < StandardError
    def initialize(configuring_location)
      super
      @message = "Yabeda was already configured in #{configuring_location}"
    end

    attr_reader :message
  end
end
