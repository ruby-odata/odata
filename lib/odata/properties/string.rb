module OData
  module Properties
    # Defines the String OData type.
    class String < OData::Property
      # Returns the property value, properly typecast
      # @return [String,nil]
      def value
        if (@value.nil? || @value.empty?) && allows_nil?
          nil
        else
          encode_value(@value)
        end
      end

      # Sets the property value
      # @params new_value [to_s,nil]
      def value=(new_value)
        validate(new_value)
        @value = new_value.nil? ? nil : encode_value(new_value.to_s)
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "'#{value}'"
      end

      # The OData type name
      def type
        'Edm.String'
      end

      # Is the property value Unicode encoded
      def is_unicode?
        options[:unicode]
      end

      # Does the property have a default value
      def has_default_value?
        not(options[:default_value].nil?)
      end

      # The default value for the property
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