module OData
  module Properties
    # Defines the Integer OData type.
    class Integer < OData::Property
      include OData::Properties::Number

      # Returns the property value, properly typecast
      # @return [Integer,nil]
      def value
        if @value.nil? && allows_nil?
          nil
        else
          @value.to_i
        end
      end

      def value=(new_value)
        validate(new_value.to_i)
        @value = new_value.to_i.to_s
      end

      # The OData type name
      def type
        'Edm.Int64'
      end

      private

      def min_value
        @min ||= -(2**63)
      end

      def max_value
        @max ||= (2**63)-1
      end
    end

    # Defines the Integer (16 bit) OData type.
    class Int16 < Integer
      def type
        'Edm.Int16'
      end

      private

      def min_value
        @min ||= -(2**15)
      end

      def max_value
        @max ||= (2**15)-1
      end
    end

    # Defines the Integer (32 bit) OData type.
    class Int32 < Integer
      def type
        'Edm.Int32'
      end

      private

      def min_value
        @min ||= -(2**31)
      end

      def max_value
        @max ||= (2**31)-1
      end
    end

    # Defines the Integer (64 bit) OData type.
    class Int64 < Integer; end

    # Defines the Byte OData type.
    class Byte < Integer
      def type
        'Edm.Byte'
      end

      private

      def min_value
        0
      end

      def max_value
        @max ||= (2**8)-1
      end
    end

    # Defines the Signed Byte OData type.
    class SByte < Integer
      def type
        'Edm.SByte'
      end

      private

      def min_value
        @min ||= -(2**7)
      end

      def max_value
        @max ||= (2**7)-1
      end
    end
  end
end