# tested via spec/core/middleware/response/raise_error_spec.rb
module ZendeskAPI
  module Error
    class ClientError < Faraday::ClientError
      attr_reader :wrapped_exception

      def to_s
        if response
          "#{super} -- #{response.method} #{response.url}"
        else
          super
        end
      end
    end

    class RecordInvalid < ClientError
      attr_accessor :errors

      def initialize(*)
        super

        if response[:body].is_a?(Hash)
          @errors = response[:body]["details"] || generate_error_msg(response[:body]) || response[:body]["error"]
        end

        @errors ||= {}
      end

      def to_s
        "#{self.class.name}: #{@errors}"
      end

      private

      def generate_error_msg(response_body)
        return unless response_body["description"] || response_body["message"]

        [
          response_body["description"],
          response_body["message"]
        ].compact.join(" - ")
      end
    end

    class NetworkError < ClientError; end
    class RecordNotFound < ClientError; end
    class RateLimited < ClientError; end
  end
end
