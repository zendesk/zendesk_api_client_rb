# `zendesk_api` gem root
module ZendeskAPI
  # A rich factory that returns a class for your searches
  class Search
    # Creates a search collection
    def self.search(client, options = {})
      if (options.keys.map(&:to_s) & %w[query external_id]).empty?
        warn "you have not specified a query for this search"
      end

      ZendeskAPI::Collection.new(client, self, options)
    end

    # Quack like a Resource
    # Creates the correct resource class from `attributes[:result_type]`
    def self.new(client, attributes)
      present_result_type = (attributes[:result_type] || attributes["result_type"]).to_s
      result_type = ZendeskAPI::Helpers.modulize_string(present_result_type)
      klass = begin
                ZendeskAPI.const_get(result_type)
              rescue NameError
                Result
              end

      (klass || Result).new(client, attributes)
    end

    def self.cbp_path_regexes
      []
    end

    class Result < Data; end

    class << self
      def resource_name
        "search"
      end
      alias resource_path resource_name

      def model_key
        "results"
      end
    end
  end

  # This will use cursor pagination by default
  class SearchExport < Search
    class << self
      def resource_name
        "search/export"
      end
      alias resource_path resource_name
    end
  end
end
