require 'odata/query/criteria'

module OData
  class Query
    # Defines the operations the OData gem knows how to support.
    SUPPORTED_OPERATIONS = [
        :filter, :order_by, :skip, :top, :select, :expand, :inline_count
    ]

    def initialize(collection)
      @collection = collection.to_s
      setup_empty_criteria_set
    end

    def <<(criteria)
      criteria_set[criteria.operation] << criteria.argument
      prune_criteria
      self
    end

    def to_s
      [collection,assemble_criteria].compact.join('?')
    end

    private

    def collection
      @collection
    end

    def criteria_set
      @criteria_set
    end

    def setup_empty_criteria_set
      criteria_set = SUPPORTED_OPERATIONS.map do |operation|
        [operation, []]
      end
      @criteria_set = Hash[criteria_set]
    end

    def prune_criteria
      criteria_set[:skip] = [criteria_set[:skip].last].compact
      criteria_set[:top] = [criteria_set[:top].last].compact
      criteria_set[:inline_count] = [criteria_set[:inline_count].last].compact
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
      criteria_set[:inline_count].empty? ? nil : "$inlinecount=#{criteria_set[:inline_count].last}"
    end

    def skip_criteria
      criteria_set[:skip].empty? ? nil : "$skip=#{criteria_set[:skip].last}"
    end

    def top_criteria
      criteria_set[:top].empty? ? nil : "$top=#{criteria_set[:top].last}"
    end
  end
end