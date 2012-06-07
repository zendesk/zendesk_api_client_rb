require 'hashie'
require 'zendesk_api/track_changes'

module ZendeskAPI
  class Trackie < Hashie::Mash
    include ZendeskAPI::TrackChanges
  end
end
