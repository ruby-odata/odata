module OData
  module Properties
    class Integer < OData::Property
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

      def type
        'Edm.Int64'
      end

      private

      def validate(value)
        if value > max_value || value < min_value
          raise ::ArgumentError, "Value is outside accepted range: #{min_value} to #{max_value}"
        end
      end

      def min_value
        @min ||= -(2**63)
      end

      def max_value
        @max ||= (2**63)-1
      end
    end

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

    class Int32 < Integer
      def type
        'Edm.Int32'
      end

      private

      def min_value
        @min ||= -(2**15)
      end

      def max_value
        @max ||= (2**15)-1
      end
    end

    class Int64 < Integer; end

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