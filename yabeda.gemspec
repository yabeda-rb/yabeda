# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yabeda/version"

Gem::Specification.new do |spec|
  spec.name          = "yabeda"
  spec.version       = Yabeda::VERSION
  spec.authors       = ["Andrey Novikov"]
  spec.email         = ["envek@envek.name"]

  spec.summary       = "Extensible framework for collecting metric for your Ruby application"
  spec.description   = <<~DESCRIPTION
    Collect statistics about how your application is performing with ease. \
    Export metrics to various monitoring systems.
  DESCRIPTION
  spec.homepage      = "https://github.com/yabeda-rb/yabeda"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "anyway_config", ">= 1.0", "< 3"
  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "dry-initializer"

  spec.required_ruby_version = ">= 2.3"
end
