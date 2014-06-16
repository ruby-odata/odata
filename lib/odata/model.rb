module OData
  module Model
    extend ::ActiveSupport::Concern

    included do
      cattr_accessor :registered_properties
      cattr_accessor :primary_key

      self.class_eval <<-EOS
        @@registered_properties = {}
        @@primary_key = nil
      EOS
    end

    module ClassMethods
      def property(name, options = {})
        register_property(name.to_s.underscore, options.merge(literal_name: name))
        create_accessors(name.to_s.underscore, options)
        register_primary_key(name.to_s.underscore) if options[:primary_key]
      end

      private

      def register_property(name, options)
        new_registered_properties = registered_properties
        new_registered_properties[name.to_sym] = options
        registered_properties = new_registered_properties
      end

      def create_accessors(name, options)
        self.class_eval do
          define_method(name) { @properties[name.to_sym] || nil }
          define_method("#{name}=") {|value| @properties[name.to_sym] = value}
        end
      end

      def register_primary_key(name)
        if primary_key.nil?
          self.class_eval <<-EOS
            @@primary_key = :#{name}
          EOS
        end
      end
    end
  end
end