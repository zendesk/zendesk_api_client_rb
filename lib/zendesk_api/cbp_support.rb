module ZendeskAPI
  # Represents the support to Cursor Based Pagination endpoints
  module CBPSupport
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Returns the paths that support CBP
    # @return [Array] of regular expressions
    # To add CBP support to a resource, add a constant called CBP_ACTIONS. See examples in resources.rb
    module ClassMethods
      def cbp_path_regexes
        const_defined?(:CBP_ACTIONS) ? const_get(:CBP_ACTIONS) : []
      end
    end
  end
end
