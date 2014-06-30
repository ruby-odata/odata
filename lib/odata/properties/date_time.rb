module OData
  module Properties
    class DateTime < OData::Property
      def value
        if @value.nil? && allows_nil?
          nil
        else
          begin
            ::DateTime.strptime(@value, '%Y-%m-%dT%H:%M:%S.%L')
          rescue ArgumentError
            ::DateTime.parse(@value)
          end
        end
      end

      def value=(new_value)
        validate(new_value)
        @value = parse_value(new_value)
      end

      def type
        'Edm.DateTime'
      end

      private

      def validate(value)
        begin
          return if value.is_a?(::DateTime)
          ::DateTime.strptime(value, '%Y-%m-%dT%H:%M:%S.%L')
        rescue => e
          raise ArgumentError, 'Value is not a date time format that can be parsed'
        end
      end

      def parse_value(value)
        parsed_value = value
        parsed_value = ::DateTime.parse(value) unless value.is_a?(::DateTime)
        parsed_value.strftime('%Y-%m-%dT%H:%M:%S.%L')
      end
    end
  end
end