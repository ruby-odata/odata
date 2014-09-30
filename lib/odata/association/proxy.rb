module OData
  class Association
    class Proxy
      attr_reader :service, :namespace, :entity_type

      def initialize(entity_type, service)
        @service = service
        @namespace = service.namespace
        @entity_type = entity_type.gsub!(/^#{namespace}\./, '')
      end

      def [](association_name)
        association = associations[association_name]
        raise ArgumentError, "unknown association: #{association_name}" if association.nil?
        association
      end

      def size
        associations.size
      end

      private

      def associations
        @associations ||= service.navigation_properties[entity_type]
      end
    end
  end
end