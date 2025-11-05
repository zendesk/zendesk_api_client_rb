module ZendeskAPI
  class Collection
    # Contains all methods related to pagination in an attempt to slim down collection.rb
    module Pagination
      DEFAULT_PAGE_SIZE = 100
      def more_results?(response)
        Helpers.present?(response["meta"]) && response["meta"]["has_more"]
      end
      alias has_more_results? more_results? # For backward compatibility with 1.33.0 and 1.34.0

      # Changes the per_page option. Returns self, so it can be chained. No execution.
      # @return [Collection] self
      def per_page(count)
        clear_cache if count
        @options["per_page"] = count
        self
      end

      # Changes the page option. Returns self, so it can be chained. No execution.
      # @return [Collection] self
      def page(number)
        clear_cache if number
        @options["page"] = number
        self
      end

      def first_page?
        !@prev_page
      end

      def last_page?
        !@next_page || @next_page == @query
      end

      private

      def page_links(body)
        if body["meta"] && body["links"]
          [body["links"]["next"], body["links"]["prev"]]
        else
          [body["next_page"], body["previous_page"]]
        end
      end

      def cbp_response?(body)
        !!(body["meta"] && body["links"])
      end

      def set_cbp_options
        @options_per_page_was = @options.delete("per_page")
        # Default to CBP by using the page param as a map
        @options.page = {size: @options_per_page_was || DEFAULT_PAGE_SIZE}
      end

      # CBP requests look like: `/resources?page[size]=100`
      # OBP requests look like: `/resources?page=2`
      def cbp_request?
        @options["page"].is_a?(Hash)
      end

      def intentional_obp_request?
        Helpers.present?(@options["page"]) && !cbp_request?
      end

      def supports_cbp?
        @resource_class.cbp_path_regexes.any? { |supported_path_regex| path.match?(supported_path_regex) }
      end

      def first_cbp_request?
        # @next_page will be nil when making the first cbp request
        @next_page.nil?
      end

      def set_page_and_count(body)
        @count = (body["count"] || @resources.size).to_i
        @next_page, @prev_page = page_links(body)

        if cbp_response?(body)
          set_cbp_response_options(body)
        elsif @next_page =~ /page=(\d+)/
          @options["page"] = Regexp.last_match(1).to_i - 1
        elsif @prev_page =~ /page=(\d+)/
          @options["page"] = Regexp.last_match(1).to_i + 1
        end
      end

      def set_cbp_response_options(body)
        @options.page = {} unless cbp_request?
        # the line above means an intentional CBP request where page[size] is passed on the query
        # this is to cater for CBP responses where we don't specify page[size] but the endpoint
        # responds CBP by default. i.e  `client.trigger_categories.fetch`
        @options.page.merge!(
          before: body["meta"]["before_cursor"],
          after: body["meta"]["after_cursor"]
        )
      end
    end
  end
end
