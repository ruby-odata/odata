module OData
  module Properties
    # Defines the Float OData type.
    class Float < OData::Property
      include OData::Properties::Number

      # Returns the property value, properly typecast
      # @return [Float,nil]
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

      # The OData type name
      def type
        'Edm.Double'
      end

      private

      def min_value
        @min ||= -(1.7 * (10**308))
      end

      def max_value
        @max ||= (1.7 * (10**308))
      end
    end

    # Defines the Double (Float) OData type.
    class Double < OData::Properties::Float; end

    # Defines the Single (Float) OData type.
    class Single < OData::Properties::Float
      # The OData type name
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