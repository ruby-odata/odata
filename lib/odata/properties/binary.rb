module OData
  module Properties
    # Defines the Binary OData type.
    class Binary < OData::Property
      # Returns the property value, properly typecast
      # @return [Integer,nil]
      def value
        if @value.nil? && allows_nil?
          nil
        else
          @value.to_i
        end
      end

      # Sets the property value
      # @params new_value [0,1,Boolean]
      def value=(new_value)
        validate(new_value)
        @value = parse_value(new_value)
      end

      # The OData type name
      def type
        'Edm.Binary'
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "binary'#{value}'"
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