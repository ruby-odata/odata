module OData
  # OData::Query provides the query interface for requesting Entities matching
  # specific criteria from an OData::EntitySet. This class should not be
  # instantiated directly, but can be. Normally you will access a Query by
  # first asking for one from the OData::EntitySet you want to query.
  class Query
    # Create a new Query for the provided EntitySet
    # @param entity_set [OData::EntitySet]
    def initialize(entity_set)
      @entity_set = entity_set
      setup_empty_criteria_set
    end

    # Instantiates an OData::Query::Criteria for the named property.
    # @param property [to_s]
    def [](property)
      OData::Query::Criteria.new(property: property)
    end

    # Adds a filter criteria to the query.
    # @param criteria
    def where(criteria)

    end

    # Adds a filter criteria to the query with 'and' logical operator.
    # @param criteria
    def and(criteria)

    end

    # Adds a filter criteria to the query with 'or' logical operator.
    # @param criteria
    def or(criteria)

    end

    # Specify properties to order the result by.
    # @param properties [Array<Symbol>]
    # @return [self]
    def order_by(*properties)
      # criteria_set[:orderby] += properties
      # self
    end

    # Specify associations to expand in the result.
    # @param associations [Array<Symbol>]
    # @return [self]
    def expand(*associations)
      # criteria_set[:expand] += associations
      # self
    end

    # Specify properties to select within the result.
    # @param properties [Array<Symbol>]
    # @return [self]
    def select(*properties)
      # criteria_set[:select] += properties
      # self
    end

    # Add skip criteria to query.
    # @param value [to_i]
    # @return [self]
    def skip(value)
      criteria_set[:skip] = value.to_i
      self
    end

    # Add limit criteria to query.
    # @param value [to_i]
    # @return [self]
    def limit(value)
      criteria_set[:top] = value.to_i
      self
    end

    # Add inline count criteria to query.
    # @return [self]
    def include_count
      criteria_set[:inline_count] = true
      self
    end

    # Convert Query to string.
    # @return [String]
    def to_s
      [entity_set.name, assemble_criteria].compact.join('?')
    end

    private

    def entity_set
      @entity_set
    end

    def criteria_set
      @criteria_set
    end

    def setup_empty_criteria_set
      @criteria_set = {
          filter:       [],
          select:       [],
          expand:       [],
          orderby:      [],
          skip:         0,
          top:          0,
          inline_count: false
      }
    end

    def assemble_criteria
      criteria = [
        filter_criteria,
        list_criteria(:orderby),
        list_criteria(:expand),
        list_criteria(:select),
        inline_count_criteria,
        paging_criteria(:skip),
        paging_criteria(:top)
      ].compact!

      criteria.empty? ? nil : criteria.join('&')
    end

    def filter_criteria
      criteria_set[:filter].empty? ? nil : "$filter=#{criteria_set[:filter].join(' and ')}"
    end

    def list_criteria(name)
      criteria_set[name].empty? ? nil : "$#{name}=#{criteria_set[:name].join(',')}"
    end

    def inline_count_criteria
      criteria_set[:inline_count] ? '$inlinecount=allpages' : nil
    end

    def paging_criteria(name)
      criteria_set[name] == 0 ? nil : "$#{name}=#{criteria_set[name]}"
    end
  end
end