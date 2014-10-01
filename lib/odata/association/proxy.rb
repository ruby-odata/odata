module OData
  class Association
    class Proxy
      def initialize(entity)
        @entity = entity
      end

      def [](association_name)
        if entity.links[association_name].nil? || associations[association_name].nil?
          raise ArgumentError, "unknown association: #{association_name}"
        end

        association_results(association_name)
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
        @entity_type ||= entity.name
      end

      def associations
        @associations ||= service.navigation_properties[entity_type]
      end

      def association_results(association_name)
        association = associations[association_name]
        link = entity.links[association_name]
        association_end = association.ends.select {|details| details.entity_type != "#{namespace}.#{entity_type}"}.first
        raise RuntimeError, 'association ends undefined' if association_end.nil?

        results = service.execute(link[:href])
        options = {
            type:         association_end.entity_type,
            namespace:    namespace,
            service_name: entity.service_name
        }

        if association_end.multiplicity == :many
          service.find_entities(results).collect do |entity_xml|
            OData::Entity.from_xml(entity_xml, options)
            #block_given? ? block.call(entity) : yield(entity)
          end
        else
          document = ::Nokogiri::XML(results.body)
          document.remove_namespaces!
          OData::Entity.from_xml(document, options)
        end
      end
    end
  end
end