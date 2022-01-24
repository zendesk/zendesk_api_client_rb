# `zendesk_api` gem root
module ZendeskAPI
  class Search
    class Result < Data; end

    # Creates a search collection
    def self.search(client, options = {})
      unless (%w{query external_id} & options.keys.map(&:to_s)).any?
        warn "you have not specified a query for this search"
      end

      ZendeskAPI::Collection.new(client, self, options)
    end

    # Quack like a Resource
    # Creates the correct resource class from `attributes[:result_type]`
    def self.new(client, attributes)
      result_type = attributes[:result_type] || attributes["result_type"]

      if result_type
        result_type = ZendeskAPI::Helpers.modulize_string(result_type)
        klass = ZendeskAPI.const_get(result_type) rescue nil
      end

      (klass || Result).new(client, attributes)
    end

    class << self
      def resource_name
        "search"
      end

      alias :resource_path :resource_name

      def model_key
        "results"
      end
    end
  end

  # This will use cursor pagination by default
  class SearchExport
    class Result < Data; end

    # Creates a search export collection
    def self.search_export(client, options = {})
      unless (%w{query external_id} & options.keys.map(&:to_s)).any?
        warn "you have not specified a query for this search"
      end

      ZendeskAPI::Collection.new(client, self, options)
    end

    # Quack like a Resource
    # Creates the correct resource class from `attributes[:result_type]`
    def self.new(client, attributes)
      result_type = attributes[:result_type] || attributes["result_type"]

      if result_type
        result_type = ZendeskAPI::Helpers.modulize_string(result_type)
        klass = ZendeskAPI.const_get(result_type) rescue nil
      end

      (klass || Result).new(client, attributes)
    end

    class << self
      def resource_name
        "search/export"
      end

      alias :resource_path :resource_name

      def model_key
        "results"
      end
    end
  end
end
