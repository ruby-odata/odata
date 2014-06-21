module OData
  module Properties
    class Boolean < OData::Property
      def value
        if @value.nil? && allows_nil?
          nil
        else
          (@value == 'true' || @value == '1')
        end
      end

      def type
        'Edm.Boolean'
      end
    end
  end
end