module OData
  class Association
    class End
      attr_reader :entity_type, :multiplicity

      def initialize(options)
        @entity_type = options[:entity_type]
        @multiplicity = self.class.multiplicity_map[options[:multiplicity].to_s]

        raise ArgumentError, ':entity_type option is required' if entity_type.nil? || entity_type == ''
        raise ArgumentError, ':multiplicity option is required' if multiplicity.nil?
        raise ArgumentError, ':multiplicity option must be one of [1, *, 0..1]' unless valid_multiplicities.include?(multiplicity)
      end

      def self.multiplicity_map
        {
            '1'     => :one,
            '*'     => :many,
            '0..1'  => :zero_to_one
        }
      end

      private

      def valid_multiplicities
        [:one, :many, :zero_to_one]
      end
    end
  end
end