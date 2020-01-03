# frozen_string_literal: true

module Yabeda
  # Class to merge tags
  class Tags
    def self.build(tags)
      ::Yabeda.general_tags.merge(tags)
    end
  end
end
