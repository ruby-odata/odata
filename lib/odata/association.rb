require 'odata/association/end'
require 'odata/association/proxy'

module OData
  class Association
    attr_reader :name, :ends
    attr_writer :entity

    def initialize(options)
      @name = options[:name]
      @ends = options[:ends] || {}

      raise ArgumentError, 'name must be provided' if name.nil? || name == ''
      raise ArgumentError, 'too many association ends' if ends.size > 2
    end
  end
end
