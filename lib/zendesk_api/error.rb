module ZendeskAPI
  module Error
    class ClientError < Faraday::Error::ClientError; end

    class RecordInvalid < ClientError
      attr_accessor :response, :errors

      def initialize(response)
        @response = response

        if response[:body].is_a?(Hash) && response[:body].key?("details")
          @errors = response[:body]["details"]
        else
          @errors = {}
        end
      end
    end

    class NetworkError < ClientError; end
    class RecordNotFound < ClientError; end
  end
end
