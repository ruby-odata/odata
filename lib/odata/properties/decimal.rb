module OData
  module Properties
    class Decimal < OData::Property
      def value
        if @value.nil? && allows_nil?
          nil
        else
          BigDecimal(@value)
        end
      end

      def value=(new_value)
        validate(BigDecimal(new_value))
        @value = new_value.to_s
      end

      def type
        'Edm.Decimal'
      end

      private

      def validate(value)
        if value > max_value || value < min_value || value.precs.first > 29
          raise ArgumentError, "Value is outside accepted range: #{min_value} to #{max_value}, or has more than 29 significant digits"
        end
      end

      def min_value
        @min ||= BigDecimal(-7.9 * (10**28), 2)
      end

      def max_value
        @max ||= BigDecimal(7.9 * (10**28), 2)
      end
    end
  end
end