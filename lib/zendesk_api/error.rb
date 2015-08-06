module ZendeskAPI
  module Error
    class ClientError < Faraday::Error::ClientError
      attr_reader :wrapped_exception
    end

    class RecordInvalid < ClientError
      attr_accessor :response, :errors

      def initialize(response)
        @response = response

        if response[:body].is_a?(Hash)
          @errors = response[:body]["details"] || response[:body]["description"]
        end

        @errors ||= {}
      end

      def to_s
        "#{self.class.name}: #{@errors.to_s}"
      end
    end

    class NetworkError < ClientError; end
    class RecordNotFound < ClientError; end
  end
end
