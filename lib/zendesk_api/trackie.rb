require_relative "track_changes"
require_relative "silent_mash"

module ZendeskAPI
  # @private
  class Trackie < SilentMash
    include ZendeskAPI::TrackChanges

    def size
      self["size"]
    end
  end
end
