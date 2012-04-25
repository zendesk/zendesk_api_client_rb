module Zendesk
  class Playlist
    attr_reader :ticket
    attr_accessor :id

    def initialize(client, id)
      @client, @id = client, id
      @ticket = nil

      @initialized = false
      @destroyed = false

      init_playlist
    end

    def each
      init_playlist unless initialized?

      while initialized? && !destroyed? && (n = self.next)
        yield n
      end
    end

    def next
      init_playlist unless initialized?
      return false if !initialized? || destroyed? 

      response = @client.connection.get("play/next.json")

      if response.status == 200
        @ticket = Ticket.new(@client, response.body["ticket"])
        @ticket
      else
        @destroyed = response.status == 204
        nil
      end
    rescue Faraday::Error::ClientError
      nil
    end

    def destroy
      response = @client.connection.delete("play.json")
      @destroyed = response.status == 204 
    rescue Faraday::Error::ClientError
      false
    end

    def destroyed?
      @destroyed
    end

    def initialized?
      @initialized
    end

    private

    def init_playlist
      response = @client.connection.get("views/#{id}/play.json")
      @initialized = response.status == 302
    rescue Faraday::Error::ClientError
    end
  end
end
