module OData
  class Query
    # Represents a discreet detail about an OData query. It also validates
    # the criteria based on what the gem knows how to support.
    class Criteria
      # Defines the options required to create a new OData::Query::Criteria.
      REQUIRED_OPTIONS = [:operation, :argument]

      # Defines the operations the OData gem knows how to support.
      SUPPORTED_OPERATIONS = [
        :filter, :order_by, :skip, :top, :select, :expand, :inlinecount
      ]

      # Creates a new OData::Query::Criteria with the supplied options.
      # @param options [Hash]
      def initialize(options = {})
        @options = process_options(options)
        validate_required_options
        validate_supported_operation
      end

      # The query operation of a particular criteria.
      # @return [Symbol]
      def operation
        options[:operation]
      end

      # The query argument of a particular criteria.
      # @return [String]
      def argument
        options[:argument]
      end

      private

      def options
        @options
      end

      def process_options(passed_options)
        new_options = passed_options.map do |key, value|
          if key.to_sym == :operation
            value = value.to_sym
          end

          [key.to_sym, value]
        end

        Hash[new_options]
      end

      def required_options
        REQUIRED_OPTIONS
      end

      def supported_operations
        SUPPORTED_OPERATIONS
      end

      def validate_required_options
        required_options.each do |required_option|
          unless options.key?(required_option)
            raise ArgumentError, "Missing required option: #{required_option}"
          end
        end
      end

      def validate_supported_operation
        unless supported_operations.include?(options[:operation])
          raise ArgumentError, "Operation not supported: #{options[:operation]}"
        end
      end
    end
  end
end