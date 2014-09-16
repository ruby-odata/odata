module OData
  module Properties
    # Defines the GUID OData type.
    class Guid < OData::Property
      # The OData type name
      def type
        'Edm.Guid'
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "guid'#{value}'"
      end
    end
  end
end