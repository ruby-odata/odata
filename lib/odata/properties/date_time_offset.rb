module OData
  module Properties
    class DateTimeOffset < OData::Property
      def value
        if @value.nil? && allow_nil?
          nil
        else
          ::DateTime.strptime(@value, '%Y-%m-%dT%H:%M:%S.%LZ%:z')
        end
      end

      def value=(new_value)
        validate(new_value)
        @value = parse_value(new_value)
      end

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