module OData
  class Association
    class Proxy
      def initialize(entity)
        @entity = entity
      end

      def [](association_name)
        association = associations[association_name]
        raise ArgumentError, "unknown association: #{association_name}" if association.nil?
        association.entity = entity
        association
      end

      def size
        associations.size
      end

      private

      attr_reader :entity

      def service
        @service ||= OData::ServiceRegistry[entity.service_name]
      end

      def namespace
        @namespace ||= service.namespace
      end

      def entity_type
        @entity_type ||= entity.type.gsub(/^#{namespace}\./, '')
      end

      def associations
        @associations ||= service.navigation_properties[entity_type].dup
      end
    end
  end
end