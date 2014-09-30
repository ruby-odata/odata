require 'odata/association/end'
require 'odata/association/proxy'

module OData
  class Association
    include Enumerable

    attr_reader :name, :ends
    attr_accessor :entity

    def initialize(options)
      @name = options[:name]
      @ends = options[:ends] || {}

      raise ArgumentError, 'name must be provided' if name.nil? || name == ''
      raise ArgumentError, 'too many association ends' if ends.size > 2
    end

    def each(&block)
      service.find_entities(feed).each do |entity_xml|
        entity = OData::Entity.from_xml(entity_xml, entity_options)
        block_given? ? block.call(entity) : yield(entity)
      end
    end

    private

    def service
      @service ||= OData::ServiceRegistry[entity.service_name]
    end

    def feed

    end
  end
end
