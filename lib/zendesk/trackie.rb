require 'hashie'
require 'zendesk/track_changes'

module Zendesk
  class Trackie < Hashie::Mash
    include Zendesk::TrackChanges
  end
end
