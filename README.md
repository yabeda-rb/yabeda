# Yabeda

**This software is Work in Progress: features will appear and disappear, API will be changed, your feedback is always welcome!** 

Extensible solution for easy setup of monitoring in your Ruby apps.

## Installation

Most of the time you don't need to add this gem to your Gemfile directly (unless you're only collecting your custom metrics):

```ruby
gem 'yabeda'
# Then add monitoring system adapter, e.g.:
# gem 'yabeda-prometheus'
```

And then execute:

    $ bundle

## Usage

 1. Declare your metrics:

    ```ruby
    Yabeda.configure do
      group :your_app
    
      counter   :bells_rang_count, "Total number of bells being rang"
      gauge     :whistles_active,  "Number of whistles ready to whistle"
      histogram :whistle_runtime,  "How long whistles are being active", unit: :seconds
    end
    ```
    
 2. Access metric in your app and use it!
 
    ```ruby
    def ring_the_bell(id)
      bell = Bell.find(id)
      bell.ring!
      Yabeda.your_app_bells_rang_count.increment({bell_size: bell.size}, by: 1)
    end

    def whistle!
      Yabeda.your_app_whistle_runtime.measure do
        # Run your code
      end
    end
    ```
    
 3. Setup collecting of metrics that do not tied to specific events in you application. E.g.: reporting your app's current state
    ```ruby
    Yabeda.configure do
      # This block will be executed periodically few times in a minute
      # (by timer or external request depending on adapter you're using) 
      # Keep it fast and simple!
      collect do
        your_app_whistles_active.set({}, Whistle.where(state: :active).count
      end
    end
    ```

  4. See the docs for the adapter you're using
  5. Enjoy!

## Roadmap (aka TODO or Help wanted)

 - Ability to change metric settings for individual adapters
 
   ```rb
   histogram :foo, comment: "say what?" do
     adapter :prometheus do
       buckets [0.01, 0.5, …, 60, 300, 3600]
     end
   end
   ```
   
 - Ability to route some metrics only for given adapter:
 
   ```rb
   adapter :prometheus do
     include_group :sidekiq
   end
   ```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yabeda-rb/yabeda.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
