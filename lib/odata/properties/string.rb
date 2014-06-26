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

      def has_default_value?
        not(options[:default_value].nil?)
      end

      def default_value
        options[:default_value]
      end

      private

      def default_options
        super.merge({
          unicode: true,
          default_value: nil
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