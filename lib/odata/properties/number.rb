module OData
  module Properties
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