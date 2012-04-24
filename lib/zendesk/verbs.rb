module Zendesk
  module Verbs
    %w{put post delete}.each do |verb|
      define_method verb do |method|
        define_method method do |*method_args|
          opts = method_args.last.is_a?(Hash) ? method_args.pop : {}
          return instance_variable_get("@#{method}") if instance_variable_defined?("@#{verb}") && !opts[:reload]

          begin
            response = @client.connection.send(verb, "#{path}/#{id}/#{method}.json") do |req|
              req.body = self.class.whitelist_attributes(opts, verb)
            end

            if (resources = response.body[self.class.resource_name]) &&
              (res = resources.find {|res| res["id"] == id})
              @attributes = Hashie::Mash.new(res)
            end

            true
          rescue Faraday::Error::ClientError => e
            false
          end
        end
      end
    end
  end
end
