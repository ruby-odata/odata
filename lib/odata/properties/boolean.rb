module OData
  module Properties
    # Defines the Boolean OData type.
    class Boolean < OData::Property
      def value
        if @value.nil? && allows_nil?
          nil
        else
          (@value == 'true' || @value == '1')
        end
      end

      def value=(new_value)
        validate(new_value)
        @value = new_value.to_s
      end

      def type
        'Edm.Boolean'
      end

      private

      def validate(value)
        unless [0,1,'0','1','true','false',true,false].include?(value)
          raise ArgumentError, 'Value is outside accepted range: true or false'
        end
      end
    end
  end
end