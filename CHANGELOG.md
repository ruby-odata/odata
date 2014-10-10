# CHANGELOG

## 0.6.14

* Changed implementation of OData::Association::Proxy#[] to properly handle
  empty associations.

## 0.6.13

* Minor bug fix in OData::Query::Result#each implementation.

## 0.6.12

* Minor bug fix in OData::Query::Result#each implementation.

## 0.6.11

* Added logic to allow OData::Query::Result#each to handle paginated results.

## 0.6.10

* Changed how associations behave with mulitiplicity of one.

## 0.6.9

* Changed how OData::Entity#from_xml functions to better work with feed results.

## 0.6.8

* Added empty checking when checking for a nil value.

## 0.6.7

* Changed how commit failures are handled to use logging instead of raising an
  error.
* Added errors array to OData::Entity.

## 0.6.6

* Updated OData::EntitySet#setup_entity_post_request to properly format primary
  key values when posting an entity.

## 0.6.5

* Fixed problem in OData::ComplexType#to_xml implementation.

## 0.6.4

* Added implementation of OData::ComplexType#type.

## 0.6.3

* Added OData::ComplexType#to_xml to make entity saving work correctly.

## 0.6.1

* Made a minor change to internals of OData::Query::Criteria.

## 0.6.0

* Added ability to handle associations in a reasonable way.

## 0.5.1-8

* Tons of changes throughout the code base

## 0.5.0

* Stopped using namespace from OData service as unique identifier in favor of
  a supplied name option when opening a service.

## 0.4.0

* Added OData::Query#execute to run query and return a result.
* Added OData::Query::Result to handle enumeration of query results.

## 0.3.2

* Refactored internals of the query interface.

## 0.3.1

* Resolved issues causing failure on Ruby 1.9 and JRuby.

## 0.3.0

* Removed dependency on ActiveSupport

## 0.2.0

* Added query interface for [System Query Options](http://www.odata.org/documentation/odata-version-3-0/odata-version-3-0-core-protocol#queryingcollections)
* Refactored internal uses of System Query Options

## 0.1.0

* Core read/write behavior for OData v1-3