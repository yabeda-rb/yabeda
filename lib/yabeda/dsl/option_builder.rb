# frozen_string_literal: true

module Yabeda
  module DSL
    # Collects options for metric initializer
    class OptionBuilder
      extend Dry::Initializer

      param :metric_klass
      param :options

      def options_from(&block)
        instance_eval(&block) if block

        return options if unknown_options.empty?

        raise ConfigurationError,
              "option '#{unknown_options.first}' is not available for #{metric_klass.name}"
      end

      def method_missing(method_name, method_args, &_block)
        if kwarg?(method_name)
          options[method_name] = method_args
        else
          super
        end
      end

      def respond_to_missing?(method_name, _args)
        kwarg?(method_name) || super
      end

      private

      def kwarg?(method_name)
        option_names.include?(method_name.to_sym)
      end

      def option_names
        definitions = metric_klass.dry_initializer.definitions.values
        definitions.select(&:option).map { |definition| definition.source.to_sym }
      end

      def unknown_options
        options.keys - option_names
      end
    end
  end
end
