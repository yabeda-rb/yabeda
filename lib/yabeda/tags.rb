# frozen_string_literal: true

module Yabeda
  # Class to merge tags
  class Tags
    def self.build(tags, group_name = nil)
      Yabeda.default_tags.dup.tap do |result|
        result.merge!(Yabeda.groups[group_name].default_tags) if group_name
        result.merge!(Yabeda.temporary_tags)
        result.merge!(tags)
      end
    end
  end
end
