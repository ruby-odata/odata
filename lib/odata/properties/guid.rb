module OData
  module Properties
    class Guid < OData::Property
      def type
        'Edm.Guid'
      end
    end
  end
end