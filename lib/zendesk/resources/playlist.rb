module Zendesk
  class Playlist
    extend Rescue

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

      response = @client.connection.get("play/next")

      if response.status == 200
        @ticket = Ticket.new(@client, response.body["ticket"])
        @ticket
      else
        @destroyed = response.status == 204
        nil
      end
    rescue Faraday::Error::ClientError => e
      puts e.message
      puts "\t#{e.response[:body].inspect}" if e.response
      nil
    end

    def destroy
      response = @client.connection.delete("play")
      @destroyed = response.status == 204 
    rescue Faraday::Error::ClientError => e
      puts e.message
      puts "\t#{e.response[:body].inspect}" if e.response
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
      response = @client.connection.get("views/#{id}/play")
      @initialized = response.status == 302
    rescue Faraday::Error::ClientError => e
      puts e.message
      puts "\t#{e.response[:body].inspect}" if e.response
    end

    rescue_client_error :next, :init_playlist
    rescue_client_error :destroy, :with => false
  end
end
