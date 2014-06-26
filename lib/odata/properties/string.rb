module OData
  module Properties
    class String < OData::Property
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
    end
  end
end