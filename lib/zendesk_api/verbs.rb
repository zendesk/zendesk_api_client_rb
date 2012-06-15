module ZendeskAPI
  # Creates put, post, delete class methods for custom resource methods.
  module Verbs
    include Rescue

    class << self
      private

      # @macro [attach] container.create_verb 
      #   @method $1(method)
      #   Executes a $1 using the passed in method as a path.
      #   Reloads the resource's attributes if any are in the response body.
      #
      #   Created method takes an optional options hash. Valid options to be passed in to the created method: reload (for caching, default: false)
      def create_verb(verb)
        define_method verb do |method|
          define_method method do |*method_args|
            opts = method_args.last.is_a?(Hash) ? method_args.pop : {}
            return instance_variable_get("@#{method}") if instance_variable_defined?("@#{verb}") && !opts[:reload]

            response = @client.connection.send(verb, "#{path}/#{method}") do |req|
              req.body = opts
            end

            if (resources = response.body[self.class.resource_name]) &&
              (res = resources.find {|res| res["id"] == id})
              @attributes = ZendeskAPI::Trackie.new(res)
              @attributes.clear_changes
            end

            true
          end

          rescue_client_error method, :with => false
        end
      end
    end

    create_verb :put
    create_verb :post
    create_verb :delete
  end
end
