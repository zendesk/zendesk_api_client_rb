module Zendesk
  class Playlist
    attr_reader :ticket, :id
    def initialize(client, id)
      @client, @id = client, id
      @ticket = nil

      response = @client.connection.get("views/#{id}/play.json")
      @destroyed = response.status != 302
    end

    def each
      while !@destroyed
        yield self.next
      end
    end

    def next
      return false if @destroyed

      response = @client.connection.get("play/next.json")

      if response.status == 200
        @ticket = Ticket.new(@client, response.body["ticket"])
        @ticket
      else
        # Depends, but definitely if 204
        @destroyed = response.status == 204 
      end
    end

    def destroy
      response = @client.connection.delete("play.json")
      @destroyed = response.status == 204 
    end
  end
end
