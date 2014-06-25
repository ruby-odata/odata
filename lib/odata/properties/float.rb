module OData
  module Properties
    class Float < OData::Property
      def value
        if @value.nil? && allows_nil?
          nil
        else
          @value.to_f
        end
      end

      def value=(new_value)
        validate(new_value.to_f)
        @value = new_value.to_f.to_s
      end

      def type
        'Edm.Double'
      end

      private

      def validate(value)
        if value > max_value || value < min_value
          raise ::ArgumentError, "Value is outside accepted range: #{min_value} to #{max_value}"
        end
      end

      def min_value
        @min ||= -(1.7 * (10**308))
      end

      def max_value
        @max ||= (1.7 * (10**308))
      end
    end

    class Double < OData::Properties::Float; end

    class Single < OData::Properties::Float
      def type
        'Edm.Single'
      end

      private

      def min_value
        @min ||= -(3.4 * (10**38))
      end

      def max_value
        @max ||= (3.4 * (10**38))
      end
    end
  end
end