require 'hashie'
require 'zendesk/core_ext/track_changes'

module Zendesk
  class Trackie < Hashie::Mash
    include Zendesk::Extensions::TrackChanges
  end
end
