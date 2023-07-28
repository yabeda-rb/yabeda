# frozen_string_literal: true

require_relative "testing"

module Yabeda
  # RSpec integration for Yabeda: custom matchers, etc
  module RSpec
  end
end

require_relative "rspec/increment_yabeda_counter"
require_relative "rspec/update_yabeda_gauge"
require_relative "rspec/measure_yabeda_histogram"
require_relative "rspec/observe_yabeda_summary"

RSpec.configure do |config|
  config.before(:suite) do
    Yabeda.configure! unless Yabeda.already_configured?
  end

  config.after(:each) do
    Yabeda::TestAdapter.instance.reset!
  end

  config.include(Yabeda::RSpec)
end
