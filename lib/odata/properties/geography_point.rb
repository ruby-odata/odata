module OData
  module Properties
    class GeographyPoint < OData::Property
      def type
        'Edm.GeographyPoint'
      end
    end
  end
end