module OData
  class Query
    # Represents a discreet criteria within an OData::Query. Should not,
    # normally, be instantiated directly.
    class Criteria
      # The property name that is the target of the criteria.
      attr_reader :property
      # The operator of the criteria.
      attr_reader :operator
      # The value of the criteria.
      attr_reader :value

      # Initializes a new criteria with provided options.
      # @param options [Hash]
      def initialize(options = {})
        @property = options[:property]
        @operator = options[:operator]
        @value    = options[:value]
      end
    end
  end
end