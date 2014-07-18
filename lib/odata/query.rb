require 'odata/query/criteria'

module OData
  class Query
    def initialize(entity_set)
      @entity_set = entity_set
      setup_empty_criteria_set
    end

    def where(criteria)

    end

    def and(criteria)

    end

    def or(criteria)

    end

    def skip(value)
      criteria_set[:skip] = value.to_i
      self
    end

    def limit(value)
      criteria_set[:top] = value.to_i
      self
    end

    def include_count
      criteria_set[:inline_count] = true
      self
    end

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
          order_by:     [],
          skip:         nil,
          top:          nil,
          inline_count: false
      }
    end

    def assemble_criteria
      criteria = [
        filter_criteria,
        order_by_criteria,
        expand_criteria,
        select_criteria,
        inline_count_criteria,
        skip_criteria,
        top_criteria
      ].compact!

      criteria.empty? ? nil : criteria.join('&')
    end

    def filter_criteria
      criteria_set[:filter].empty? ? nil : "$filter=#{criteria_set[:filter].join(' and ')}"
    end

    def order_by_criteria
      criteria_set[:order_by].empty? ? nil : "$orderby=#{criteria_set[:order_by].join(',')}"
    end

    def expand_criteria
      criteria_set[:expand].empty? ? nil : "$expand=#{criteria_set[:expand].join(',')}"
    end

    def select_criteria
      criteria_set[:select].empty? ? nil : "$select=#{criteria_set[:select].join(',')}"
    end

    def inline_count_criteria
      criteria_set[:inline_count] ? '$inlinecount=allpages' : nil
    end

    def skip_criteria
      (criteria_set[:skip].nil? || criteria_set[:skip] == 0) ? nil : "$skip=#{criteria_set[:skip]}"
    end

    def top_criteria
      (criteria_set[:top].nil? || criteria_set[:top] == 0) ? nil : "$top=#{criteria_set[:top]}"
    end
  end
end