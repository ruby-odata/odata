module OData
  module Properties
    # Defines the Integer OData type.
    class Integer < OData::Property
      include OData::Properties::Number

      # Returns the property value, properly typecast
      # @return [Integer,nil]
      def value
        if (@value.nil? || @value.empty?) && allows_nil?
          nil
        else
          @value.to_i
        end
      end

      # Sets the property value
      # @params new_value [to_i]
      def value=(new_value)
        validate(new_value.to_i)
        @value = new_value.to_i.to_s
      end

      # The OData type name
      def type
        'Edm.Int64'
      end

      private

      def exponent_size
        63
      end

      def min_value
        @min ||= -(2**exponent_size)
      end

      def max_value
        @max ||= (2**exponent_size)-1
      end
    end

    # Defines the Integer (16 bit) OData type.
    class Int16 < Integer
      # The OData type name
      def type
        'Edm.Int16'
      end

      private

      def exponent_size
        15
      end
    end

    # Defines the Integer (32 bit) OData type.
    class Int32 < Integer
      # The OData type name
      def type
        'Edm.Int32'
      end

      private

      def exponent_size
        31
      end
    end

    # Defines the Integer (64 bit) OData type.
    class Int64 < Integer; end

    # Defines the Byte OData type.
    class Byte < Integer
      # The OData type name
      def type
        'Edm.Byte'
      end

      private

      def exponent_size
        8
      end

      def min_value
        0
      end
    end

    # Defines the Signed Byte OData type.
    class SByte < Integer
      # The OData type name
      def type
        'Edm.SByte'
      end

      private

      def exponent_size
        7
      end
    end
  end
end