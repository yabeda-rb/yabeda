# frozen_string_literal: true

module Yabeda
  # Class to merge tags
  class Tags
    def self.build(tags, group_name = nil)
      Yabeda.groups[group_name].default_tags.merge(Yabeda.temporary_tags).merge(tags)
    end
  end
end
