module OData
  class Property
    attr_reader :name
    attr_accessor :value

    def initialize(name, value, options = {})
      @name = name.to_s
      @value = value.nil? ? nil : value.to_s
      @options = default_options.merge(options)
    end

    def type
      raise NotImplementedError
    end

    def ==(other)
      self.value == other.value
    end

    def allows_nil?
      @allows_nil ||= options[:allows_nil]
    end

    def max_length
      raise NotImplementedError
    end

    def fixed_length
      raise NotImplementedError
    end

    def precision
      raise NotImplementedError
    end

    def scale
      raise NotImplementedError
    end

    def is_unicode?
      raise NotImplementedError
    end

    def collation
      raise NotImplementedError
    end

    def srid
      raise NotImplementedError
    end

    def default_value
      raise NotImplementedError
    end

    def concurrency_mode
      @concurrecy_mode ||= options[:concurrency_mode]
    end

    private

    def default_options
      {
          allows_nil:       true,
          concurrency_mode: :none
      }
    end

    def options
      @options
    end
  end
end