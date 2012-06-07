require 'hashie'
require 'zendesk/track_changes'

module ZendeskAPI
  class Trackie < Hashie::Mash
    include ZendeskAPI::TrackChanges
  end
end
