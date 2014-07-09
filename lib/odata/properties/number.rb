module OData
  module Properties
    # Defines common behavior for OData numeric types.
    module Number
      private

      def validate(value)
        if value > max_value || value < min_value
          raise ::ArgumentError, "Value is outside accepted range: #{min_value} to #{max_value}"
        end
      end
    end
  end
end