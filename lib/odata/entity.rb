module OData
  class Entity
    attr_reader :type, :namespace

    def initialize(options = {})
      @type = options[:type]
      @namespace = options[:namespace]
      @properties = {}
    end

    def name
      @name ||= type.gsub(/#{namespace}\./, '')
    end

    def [](property_name)
      @properties[property_name.to_s].value
    end

    def self.from_xml(xml_doc, options = {})
      entity = OData::Entity.new(options)
      entity.instance_eval do
        xml_doc.xpath('//content/properties/*').each do |property_xml|
          property_name = property_xml.name
          if property_xml.attributes['null'] &&
              property_xml.attributes['null'].value == 'true'
            value = nil
            value_type = service.get_property_type(name, property_name)
          else
            value_type = property_xml.attributes['type'].value
            value = property_xml.content
          end
          klass_name = value_type.gsub(/^Edm\./, '')
          property = "OData::Properties::#{klass_name}".constantize.new(property_name, value)
          set_property(property_name, property)
        end

        begin
          title_value = xml_doc.xpath('//title').first.content
          property_name = service.get_title_property_name(name)
          value_type = service.get_property_type(name, property_name)
          klass_name = value_type.gsub(/^Edm\./, '')
          property = "OData::Properties::#{klass_name}".constantize.new(property_name, title_value)
          set_property(property_name, property)
        end

        begin
          summary_value = xml_doc.xpath('//summary').first.content
          property_name = service.get_summary_property_name(name)
          value_type = service.get_property_type(name, property_name)
          klass_name = value_type.gsub(/^Edm\./, '')
          property = "OData::Properties::#{klass_name}".constantize.new(property_name, summary_value)
          set_property(property_name, property)
        end
      end
      entity
    end

    private

    def service
      @service ||= OData::ServiceRegistry[namespace]
    end

    def set_property(name, odata_property)
      @properties[name.to_s] = odata_property.dup
    end
  end
end