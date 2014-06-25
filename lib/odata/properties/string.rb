module OData
  module Properties
    class String < OData::Property
      def type
        'Edm.String'
      end
    end
  end
end