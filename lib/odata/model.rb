module OData
  # Provides a convenient way to represent OData entities as Ruby objects.
  # Instances that include this module gain the ability to define how to map
  # OData properties to attributes as well as the ability to query and persist
  # data to the underlying OData service.
  #
  # If the module detects the presence of Rails, along with ActiveModel::Model
  # it will automatically mixin support ActiveModel::Model to provide better
  # integration with Rails apps.
  module Model
    extend ::ActiveSupport::Concern
    include ::ActiveModel::Model if defined?(::Rails) && defined?(::ActiveModel::Model)

    included do
      cattr_accessor :registered_properties
      cattr_accessor :primary_key

      self.class_eval <<-EOS
        @@registered_properties = {}
        @@primary_key = nil
      EOS
    end

    def convert_value_for_type(value, type)
      return nil if value.nil? || type.nil?
      if type =~ /Int(16|32|64)$/
        value.to_i
      elsif type =~ /Boolean$/
        (value == 'true' || value == '1')
      elsif type =~ /(Decimal|Double|Single)$/
        value.to_f
      elsif type =~ /DateTime$/
        DateTime.parse(value)
      else
        value.to_s
      end
    end

    module ClassMethods
      # Returns the class' name
      def model_name
        self.to_s.demodulize
      end

      # Pluralizes #model_name for OData requests
      def odata_name
        model_name.pluralize
      end

      def load_from_feed(feed_hash)
        loaded_instance = self.new
        feed_hash.each do |attribute_name, details|
          loaded_instance.instance_eval do
            @properties ||= {}
            @properties[attribute_name] = convert_value_for_type(details[:value], details[:type])
          end
        end
        loaded_instance
      end

      # Define a property and it's options
      #
      # @param name [to_s] the literal property name expected by the OData service
      # @param options [Hash] options for setting up the property
      def property(name, options = {})
        register_property(name.to_s.underscore, {literal_name: name}.merge(options))
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
          if options[:entity_title]
            define_method(name) { @properties[:title] || nil }
            define_method("#{name}=") {|value| @properties[:title] = value}
          elsif options[:entity_summary]
            define_method(name) { @properties[:summary] || nil }
            define_method("#{name}=") {|value| @properties[:summary] = value}
          else
            define_method(name) { @properties[name.to_sym] || nil }
            define_method("#{name}=") {|value| @properties[name.to_sym] = value}
          end
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