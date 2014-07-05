# OData

[![Build Status](https://travis-ci.org/plainprogrammer/odata.svg?branch=master)](https://travis-ci.org/plainprogrammer/odata)
[![Code Climate](https://codeclimate.com/github/plainprogrammer/odata.png)](https://codeclimate.com/github/plainprogrammer/odata)
[![Coverage](https://codeclimate.com/github/plainprogrammer/odata/coverage.png)](https://codeclimate.com/github/plainprogrammer/odata)
[![Gem Version](https://badge.fury.io/rb/odata.svg)](http://badge.fury.io/rb/odata)
[![Dependency Status](https://gemnasium.com/plainprogrammer/odata.svg)](https://gemnasium.com/plainprogrammer/odata)
[![Documentation](http://inch-ci.org/github/plainprogrammer/odata.png?branch=master)](http://rubydoc.info/github/plainprogrammer/odata/master/frames)

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

This one call will setup the service and allow for the discovery of everything
the other parts of the OData gem need to function. The two methods you will
want to remember from `OData::Service` are `#service_url` and `#namespace`. Both
of these methods are available on instances and will allow for lookup in the
`OData::ServiceRegistry`, should you need it.

Using either the service URL or the namespace provided by a service's CSDL
schema will allow for quick lookup in the `OData::ServiceRegistry` like such:

    OData::ServiceRegistry['http://services.odata.org/OData/OData.svc']
    OData::ServiceRegistry['ODataDemo']

Both of the above calls would retrieve the same service from the registry. At
the moment there is no protection against namespace collisions provided in
`OData::ServiceRegistry`. So, looking up services by their service URL is the
most exact method, but lookup by namespace is provided for convenience.

### Entity Sets

When it comes to reading data from an OData service the most typical way will
be via `OData::EntitySet` instances. Under normal circumstances you should
never need to worry about an `OData::EntitySet` directly. For example, to get
an `OData::EntitySet` for the products in the ODataDemo service simply access
the entity set through the service like this:

    svc = OData::Service.open('http://services.odata.org/OData/OData.svc')
    products = svc['Products'] # => OData::EntitySet

`OData::EntitySet` instances implement the `Enumerable` module, meaning you can
work with them very naturally, like this:

    products.each do |entity|
      entity # => OData::Entity for type Product
    end

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

## Contributing

1. Fork it ( https://github.com/[my-github-username]/odata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
