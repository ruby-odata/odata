module OData
  module Properties
    class Binary < OData::Property
      def value
        if @value.nil? && allows_nil?
          nil
        else
          @value.to_i
        end
      end

      def value=(new_value)
        validate(new_value)
        @value = parse_value(new_value)
      end

      def type
        'Edm.Binary'
      end

      private

      def parse_value(value)
        if value == 0 || value == '0' || value == false
          '0'
        else
          '1'
        end
      end

      def validate(value)
        unless [0,1,'0','1',true,false].include?(value)
          raise ArgumentError, 'Value is outside accepted range: 0 or 1'
        end
      end
    end
  end
end