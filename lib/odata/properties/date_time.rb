module OData
  module Properties
    # Defines the DateTime OData type.
    class DateTime < OData::Property
      # Returns the property value, properly typecast
      # @return [DateTime, nil]
      def value
        if (@value.nil? || @value.empty?) && allows_nil?
          nil
        else
          begin
            ::DateTime.strptime(@value, '%Y-%m-%dT%H:%M:%S.%L')
          rescue ArgumentError
            ::DateTime.parse(@value)
          end
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
        'Edm.DateTime'
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "datetime'#{value}'"
      end

      private

      def validate(value)
        begin
          return if value.nil? && allows_nil?
          return if value.is_a?(::DateTime)
          ::DateTime.strptime(value, '%Y-%m-%dT%H:%M:%S.%L')
        rescue
          raise ArgumentError, 'Value is not a date time format that can be parsed'
        end
      end

      def parse_value(value)
        return value if value.nil? && allows_nil?
        parsed_value = value
        parsed_value = ::DateTime.parse(value) unless value.is_a?(::DateTime)
        parsed_value.strftime('%Y-%m-%dT%H:%M:%S.%L')
      end
    end
  end
end