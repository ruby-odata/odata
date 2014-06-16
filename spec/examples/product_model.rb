class Product
  include OData::Model

  property 'ID', primary_key: true
  property 'Name'
  property 'Description'
  property 'ReleaseDate'
  property 'DiscontinuedDate'
  property 'Rating'
  property 'Price'
end