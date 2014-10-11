module OData
  module Properties
    # Defines the Time OData type.
    class Time < OData::Property
      # Returns the property value, properly typecast
      # @return [Time,nil]
      def value
        if (@value.nil? || @value.empty?) && allow_nil?
          nil
        else
          ::Time.strptime(@value, '%H:%M:%S%:z')
        end
      end

      # Sets the property value
      # @params new_value [Time]
      def value=(new_value)
        validate(new_value)
        @value = parse_value(new_value)
      end

      # The OData type name
      def type
        'Edm.Time'
      end

      private

      def validate(value)
        unless value.is_a?(::Time)
          raise ArgumentError, 'Value is not a time object'
        end
      end

      def parse_value(value)
        value.strftime('%H:%M:%S%:z')
      end
    end
  end
end