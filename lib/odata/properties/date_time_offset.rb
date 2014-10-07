module OData
  module Properties
    # Defines the DateTimeOffset OData type.
    class DateTimeOffset < OData::Property
      # Returns the property value, properly typecast
      # @return [DateTime,nil]
      def value
        if (@value.nil? || @value.empty?) && allow_nil?
          nil
        else
          ::DateTime.strptime(@value, '%Y-%m-%dT%H:%M:%S.%LZ%:z')
        end
      end

      # Sets the property value
      # @params new_value [DateTime]
      def value=(new_value)
        validate(new_value)
        @value = parse_value(new_value)
      end

      # The OData type name
      def type
        'Edm.DateTimeOffset'
      end

      private

      def validate(value)
        unless value.is_a?(::DateTime)
          raise ArgumentError, 'Value is not a date time format that can be parsed'
        end
      end

      def parse_value(value)
        parsed_value = value
        parsed_value = ::DateTime.parse(value) unless value.is_a?(::DateTime)
        parsed_value.strftime('%Y-%m-%dT%H:%M:%S.%LZ%:z')
      end
    end
  end
end