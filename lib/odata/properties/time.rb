module OData
  module Properties
    class Time < OData::Property
      def value
        if @value.nil? && allow_nil?
          nil
        else
          ::Time.strptime(@value, '%H:%M:%S%:z')
        end
      end

      def value=(new_value)
        validate(new_value)
        @value = parse_value(new_value)
      end

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