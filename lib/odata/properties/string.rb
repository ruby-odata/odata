module OData
  module Properties
    class String < OData::Property
      def value
        if @value.nil? && allows_nil?
          nil
        else
          encode_value(@value)
        end
      end

      def value=(new_value)
        validate(new_value)
        @value = new_value.nil? ? nil : encode_value(new_value.to_s)
      end

      def type
        'Edm.String'
      end

      def is_unicode?
        options[:unicode]
      end

      private

      def default_options
        super.merge({
            unicode: true
        })
      end

      def validate(new_value)
        if new_value.nil? && !allows_nil?
          raise ArgumentError, 'This property does not allow for nil values to be set'
        end
      end

      def encode_value(new_value)
        if options[:unicode]
          new_value.encode(Encoding::UTF_8)
        else
          new_value.encode(Encoding::ASCII)
        end
      end
    end
  end
end