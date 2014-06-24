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
        @value = new_value.to_i.to_s
      end

      def type
        'Edm.Int64'
      end
    end

    class Int16 < Integer
      def type
        'Edm.Int16'
      end
    end

    class Int32 < Integer
      def type
        'Edm.Int32'
      end
    end

    class Int64 < Integer
      # def type
      #   'Edm.Int64'
      # end
    end
  end
end