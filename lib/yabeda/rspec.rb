require_relative './testing'

require_relative './rspec/be_incremented'
require_relative './rspec/be_set'
require_relative './rspec/be_measured'

::RSpec.configure do |config|
  config.before(:suite) do
    Yabeda.configure! unless Yabeda.already_configured?
  end

  config.after(:each) do
    Yabeda::TestAdapter.instance.reset!
  end

  config.include(Yabeda::RSpec)
end
