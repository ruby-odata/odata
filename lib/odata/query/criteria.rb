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

      # Sets up equality operator.
      # @param value [to_s]
      # @return [self]
      def eq(value)
        set_operator_and_value(:eq, value)
      end

      # Sets up non-equality operator.
      # @param value [to_s]
      # @return [self]
      def ne(value)
        set_operator_and_value(:ne, value)
      end

      # Sets up greater-than operator.
      # @param value [to_s]
      # @return [self]
      def gt(value)
        set_operator_and_value(:gt, value)
      end

      # Sets up greater-than-or-equal operator.
      # @param value [to_s]
      # @return [self]
      def ge(value)
        set_operator_and_value(:ge, value)
      end

      # Sets up less-than operator.
      # @param value [to_s]
      # @return [self]
      def lt(value)
        set_operator_and_value(:lt, value)
      end

      # Sets up less-than-or-equal operator.
      # @param value [to_s]
      # @return [self]
      def le(value)
        set_operator_and_value(:le, value)
      end

      # Returns criteria as query-ready string.
      def to_s
        "#{property.name} #{operator} #{property.url_value}"
      end

      private

      def set_operator_and_value(operator, value)
        property.value = value

        @operator = operator
        @value = value
        self
      end
    end
  end
end