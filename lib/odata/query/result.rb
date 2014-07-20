module OData
  class Query
    # Represents the results of executing a OData::Query.
    # @api private
    class Result
      include Enumerable

      # Initialize a result with the query and the result in XML.
      # @param query [OData::Query]
      # @param xml_result [Nokogiri::XML]
      def initialize(query, xml_result)
        @query      = query
        @xml_result = xml_result
      end

      # Provided for Enumerable functionality
      # @param block [block] a block to evaluate
      # @return [OData::Entity] each entity in turn for the query result
      def each(&block)

      end
    end
  end
end