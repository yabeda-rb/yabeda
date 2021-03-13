# frozen_string_literal: true

module Yabeda
  # Class to merge tags
  class Tags
    def self.build(tags, group)
      group_tags = group&.default_tags || Concurrent::Hash.new
      ::Yabeda.default_tags.merge(group_tags).merge(Yabeda.temporary_tags).merge(tags)
    end

    def self.tag_group(group = nil)
      @tag_group ||= Concurrent::Hash.new
      @tag_group[group] ||= Concurrent::Hash.new
    end
  end
end
