module Examples
  class Product
    include OData::Model

    property 'ID', primary_key: true
    property 'Name', entity_title: true
    property 'Description', entity_summary: true
    property 'ReleaseDate'
    property 'DiscontinuedDate'
    property 'Rating'
    property 'Price'
  end
end