# CHANGELOG

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