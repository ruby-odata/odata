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
    end
  end
end