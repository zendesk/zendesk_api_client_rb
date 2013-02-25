require 'hashie'
require 'zendesk_api/track_changes'

module ZendeskAPI
  # @private
  class Trackie < Hashie::Mash
    include ZendeskAPI::TrackChanges

    def size
      self['size']
    end

  end
end
