module ZendeskAPI
  class Search < Data
    class Result < Data; end

    # Creates a search collection
    def self.search(client, options = {})
      unless (%w{query external_id} & options.keys.map(&:to_s)).any?
        warn "you have not specified a query for this search"
      end

      ZendeskAPI::Collection.new(client, self, options)
    end

    # Quack like a Resource
    # Creates the correct resource class from the result_type passed in
    def self.new(client, attributes)
      result_type = attributes["result_type"]

      if result_type
        result_type = result_type.capitalize
        klass = ZendeskAPI.const_get(result_type) rescue nil
      end

      (klass || Result).new(client, attributes)
    end

    class << self
      def resource_name
        'search'
      end

      alias :resource_path :resource_name

      def model_key
        'results'
      end
    end
  end
end
