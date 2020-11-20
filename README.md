# Yabeda

[![Gem Version](https://badge.fury.io/rb/yabeda.svg)](https://rubygems.org/gems/yabeda) [![Build Status](https://travis-ci.org/yabeda-rb/yabeda.svg?branch=master)](https://travis-ci.org/yabeda-rb/yabeda)

**This software is Work in Progress: features will appear and disappear, API will be changed, your feedback is always welcome!**

Extendable solution for easy setup of monitoring in your Ruby apps.

<a href="https://evilmartians.com/?utm_source=yabeda&utm_campaign=project_page">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
</a>

> Read more about Yabeda and the reasoning behind it in Martian Chronicles: [“Meet Yabeda: Modular framework for instrumenting Ruby applications”](https://evilmartians.com/chronicles/meet-yabeda-modular-framework-for-instrumenting-ruby-applications)

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
      group :your_app do
        counter   :bells_rang_count, comment: "Total number of bells being rang", tags: %i[bell_size]
        gauge     :whistles_active,  comment: "Number of whistles ready to whistle"
        histogram :whistle_runtime do
          comment "How long whistles are being active"
          unit :seconds
        end
      end
    end
    ```

 2. After your application was initialized and all metrics was declared, you need to apply Yabeda configuration:

    ```ruby
    Yabeda.configure!
    ```

    _If you're using Ruby on Rails then it will be configured automatically!_

 3. Access metric in your app and use it!

    ```ruby
    def ring_the_bell(id)
      bell = Bell.find(id)
      bell.ring!
      Yabeda.your_app.bells_rang_count.increment({bell_size: bell.size}, by: 1)
    end

    def whistle!
      Yabeda.your_app.whistle_runtime.measure do
        # Run your code
      end
    end
    ```

 4. Setup collecting of metrics that do not tied to specific events in you application. E.g.: reporting your app's current state
    ```ruby
    Yabeda.configure do
      # This block will be executed periodically few times in a minute
      # (by timer or external request depending on adapter you're using)
      # Keep it fast and simple!
      collect do
        your_app.whistles_active.set({}, Whistle.where(state: :active).count)
      end
    end
    ```

  5. _Optionally_ setup default tags that will be added to all metrics
     ```ruby
     Yabeda.configure do
       default_tag :rails_environment, 'production'
     end

     # You can redefine them for limited amount of time
     Yabeda.with_tags(rails_environment: 'staging') do
       Yabeda.your_app.bells_rang_count.increment({bell_size: bell.size}, by: 1)
     end
     ```

  6. See the docs for the adapter you're using
  7. Enjoy!

## Available monitoring system adapters

 - [Prometheus](https://github.com/yabeda-rb/yabeda-prometheus)
 - [Datadog](https://github.com/yabeda-rb/yabeda-datadog)
 - [NewRelic](https://github.com/yabeda-rb/yabeda-newrelic)
 - [Statsd](https://github.com/asusikov/yabeda-statsd)
 - _…and more! You can write your own adapter and open a pull request to add it into this list._

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

### Releasing

 1. Bump version number in `lib/yabeda/version.rb`

    In case of pre-releases keep in mind [rubygems/rubygems#3086](https://github.com/rubygems/rubygems/issues/3086) and check version with command like `Gem::Version.new(Yabeda::VERSION).to_s`

 2. Fill `CHANGELOG.md` with missing changes, add header with version and date.

 3. Make a commit:

    ```sh
    git add lib/yabeda/version.rb CHANGELOG.md
    version=$(ruby -r ./lib/yabeda/version.rb -e "puts Gem::Version.new(Yabeda::VERSION)")
    git commit --message="${version}: " --edit
    ```

 3. Create annotated tag:

    ```sh
    git tag v${version} --annotate --message="${version}: " --edit --sign
    ```

 4. Fill version name into subject line and (optionally) some description (changes will be taken from changelog and appended automatically)

 5. Push it:

    ```sh
    git push --follow-tags
    ```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yabeda-rb/yabeda.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[yabeda-rails]: https://github.com/yabeda-rb/yabeda-rails/ "Yabeda plugin for collecting and exporting basic metrics for Rails applications"
