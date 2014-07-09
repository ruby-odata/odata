module OData
  module Properties
    # Defines the GUID OData type.
    class Guid < OData::Property
      # The OData type name
      def type
        'Edm.Guid'
      end
    end
  end
end