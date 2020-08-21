# frozen_string_literal: true

module Yabeda
  module Rails
    class Railtie < ::Rails::Railtie # :nodoc:
      config.after_initialize do
        Yabeda.configure! unless Yabeda.already_configured?
      end
    end
  end
end
