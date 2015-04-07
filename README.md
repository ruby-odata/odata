# OData
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/ruby-odata/odata?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://travis-ci.org/ruby-odata/odata.svg?branch=master)](https://travis-ci.org/ruby-odata/odata)
[![Code Climate](https://codeclimate.com/github/ruby-odata/odata.png)](https://codeclimate.com/github/ruby-odata/odata)
[![Coverage](https://codeclimate.com/github/ruby-odata/odata/coverage.png)](https://codeclimate.com/github/ruby-odata/odata)
[![Gem Version](https://badge.fury.io/rb/odata.svg)](http://badge.fury.io/rb/odata)
[![Dependency Status](https://gemnasium.com/ruby-odata/odata.svg)](https://gemnasium.com/ruby-odata/odata)
[![Documentation](http://inch-ci.org/github/ruby-odata/odata.png?branch=master)](http://rubydoc.info/github/ruby-odata/odata/master/frames)

The OData gem provides a simple wrapper around the OData API protocol. It has
the ability to automatically inspect compliant APIs and expose the relevant
Ruby objects dynamically. It also provides a set of code generation tools for
quickly bootstrapping more custom service libraries.

## Installation

Add this line to your application's Gemfile:

    gem 'odata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install odata

## Usage

### Services & the Service Registry

The OData gem provides a number of core classes, the two most basic ones are
the `OData::Service` and the `OData::ServiceRegistry`. The only time you will need
to worry about the `OData::ServiceRegistry` is when you have multiple OData
services you are interacting with that you want to keep straight easily. The
nice thing about `OData::Service` is that it automatically registers with the
registry on creation, so there is no manual interaction with the registry
necessary.

To create an `OData::Service` simply provide the location of a service endpoint
to it like this:

    OData::Service.open('http://services.odata.org/OData/OData.svc')

You may also provide an options hash after the URL. It is suggested that you
supply a name for the service via this hash like so:

    OData::Service.open('http://services.odata.org/OData/OData.svc', name: 'ODataDemo')

This one call will setup the service and allow for the discovery of everything
the other parts of the OData gem need to function. The two methods you will
want to remember from `OData::Service` are `#service_url` and `#name`. Both
of these methods are available on instances and will allow for lookup in the
`OData::ServiceRegistry`, should you need it.

Using either the service URL or the name provided as an option when creating an
`OData::Service` will allow for quick lookup in the `OData::ServiceRegistry`
like such:

    OData::ServiceRegistry['http://services.odata.org/OData/OData.svc']
    OData::ServiceRegistry['ODataDemo']

Both of the above calls would retrieve the same service from the registry. At
the moment there is no protection against name collisions provided in
`OData::ServiceRegistry`. So, looking up services by their service URL is the
most exact method, but lookup by name is provided for convenience.

### Authentication

When authenticating with your service you can set parameters to the Typhoeus gem
which uses libcurl. Use the **:typhoeus** option to set your authentication.

For example using **ntlm** authentication:

    conn = OData::Service.open('http://services.odata.org/OData/OData.svc', {
        name: 'ODataDemo',
        typhoeus: {
          username: 'username',
          password: 'password',
          httpauth: :ntlm
        }
    })

For more authentication options see [libcurl](http://curl.haxx.se/libcurl/c/CURLOPT_HTTPAUTH.html) or
[typhoeus](https://github.com/typhoeus/typhoeus).

### Headers

You can set the headers with the **:typhoeus** param like so:

    conn = OData::Service.open('http://services.odata.org/OData/OData.svc', {
        name: 'ODataDemo',
        typhoeus: {
          headers: {
            "DataServiceVersion" => "2.0"
          }
        }
    })

### Entity Sets

When it comes to reading data from an OData service the most typical way will
be via `OData::EntitySet` instances. Under normal circumstances you should
never need to worry about an `OData::EntitySet` directly. For example, to get
an `OData::EntitySet` for the products in the ODataDemo service simply access
the entity set through the service like this:

    svc = OData::Service.open('http://services.odata.org/OData/OData.svc')
    products = svc['ProductsSet'] # => OData::EntitySet

`OData::EntitySet` instances implement the `Enumerable` module, meaning you can
work with them very naturally, like this:

    products.each do |entity|
      entity # => OData::Entity for type Product
    end

You can get a list of all your entity sets like this:

    svc.entity_sets

#### Count
Some versions of Microsoft CRM do not support count.

    products.count

#### Collections
You can you the following methods to grab a collection of Entities:

    products.each do |entity|
      ...
    end

The first entity object returns a single entity object.

    products.first

first(x) returns an array of entity objects.

    products.first(x)

#### Find a certain Entity

    svc['ProductsSet']['<guid of entity>']


### Entities

`OData::Entity` instances represent individual entities, or records, in a given
service. They are returned primarily through interaction with instances of
`OData::EntitySet`. You can access individual properties on an `OData::Entity`
like so:

    product = products.first # => OData::Entity
    product['Name']  # => 'Bread'
    product['Price'] # => 2.5 (Float)

Individual properties on an `OData::Entity` are automatically typecast by the
gem, so you don't have to worry about too much when working with entities. The
way this is implemented internally guarantees that an `OData::Entity` is always
ready to save back to the service or `OData::EntitySet`, which you do like so:

    svc['Products'] << product # Write back to the service
    products << product        # Write back to the Entity Set

You can get a list of all your entities like this:

    svc.entity_types

### Queries

`OData::Query` instances form the base for finding specific entities within an
`OData::EntitySet`. A query object exposes a number of capabilities based on
the [System Query Options](http://www.odata.org/documentation/odata-version-3-0/odata-version-3-0-core-protocol#queryingcollections)
provided for in the OData specification. Below is just a partial example of
what is possible:

    query = svc['Products'].query
    query.where(query[:Price].lt(15))
    query.where(query[:Rating].gt(3))
    query.limit(3)
    query.skip(2)
    query.order_by("Name")
    query.select("Name,CreatedBy")
    query.inline_count
    results = query.execute
    results.each {|product| puts product['Name']}

The process of querying is kept purposely verbose to allow for lazy behavior to
be implemented at higher layers. Internally, `OData::Query` relies on the
`OData::Query::Criteria` for the way the `where` method works. You should refer
to the published RubyDocs for full details on the various capabilities:

 * [OData::Query](http://rubydoc.info/github/ruby-odata/odata/master/OData/Query)
 * [OData::Query::Criteria](http://rubydoc.info/github/ruby-odata/odata/master/OData/Query/Criteria)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/odata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
