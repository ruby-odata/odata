module OData
  class Query
    # Represents the results of executing a OData::Query.
    # @api private
    class Result
      include Enumerable

      attr_reader :query

      # Initialize a result with the query and the result.
      # @param query [OData::Query]
      # @param result [Typhoeus::Result]
      def initialize(query, result)
        @query      = query
        @result     = result
      end

      # Provided for Enumerable functionality
      # @param block [block] a block to evaluate
      # @return [OData::Entity] each entity in turn for the query result
      def each(&block)
        process_results(&block)
        until next_page.nil?
          service.execute(next_page_url)
          process_results(&block)
        end
      end

      private

      attr_accessor :result

      def service
        query.entity_set.service
      end

      def entity_options
        query.entity_set.entity_options
      end

      def process_results(&block)
        service.find_entities(result).each do |entity_xml|
          entity = OData::Entity.from_xml(entity_xml, entity_options)
          block_given? ? block.call(entity) : yield(entity)
        end
      end

      def next_page
        doc = ::Nokogiri::XML(result.body)
        doc.remove_namespaces!
        doc.xpath("/feed/link[@rel='next']").first
      end

      def next_page_url
        next_page.attributes['href'].value.gsub(service.service_url, '')
      end
    end
  end
end
