# OData

[![Build Status](https://travis-ci.org/plainprogrammer/odata.svg?branch=master)](https://travis-ci.org/plainprogrammer/odata)
[![Code Climate](https://codeclimate.com/github/plainprogrammer/odata.png)](https://codeclimate.com/github/plainprogrammer/odata)
[![Coverage](https://codeclimate.com/github/plainprogrammer/odata/coverage.png)](https://codeclimate.com/github/plainprogrammer/odata)
[![Gem Version](https://badge.fury.io/rb/odata.svg)](http://badge.fury.io/rb/odata)

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

The OData gem provides a number of core classes, the two most basic ones are
the OData::Service and the OData::ServiceRegistry. The only time you will need
to worry about the OData::ServiceRegistry is when you have multiple OData
services you are interacting with that you want to keep straight easily. The
nice thing about OData::Service is that it automatically registers with the
registry on creation, so there is no manual interaction with the registry
necessary.

To create an OData::Service simply provide the location of a service endpoint
to it like this:

    OData::Service.open('http://services.odata.org/OData/OData.svc')

This one call will setup the service and allow for the discovery of everything
the other parts of the OData gem need to function. The two methods you will
want to remember from OData::Service are `#service_url` and `#namespace`. Both
of these methods are available on instances and will allow for lookup in the
OData::ServiceRegistry, should you need it.

Using either the service URL or the namespace provided by a service's CSDL
schema will allow for quick lookup in the OData::ServiceRegistry like such:

    OData::ServiceRegistry['http://services.odata.org/OData/OData.svc']
    OData::ServiceRegistry['ODataDemo']

Both of the above calls would retrieve the same service from the registry. At
the moment there is no protection against namespace collisions provided in
OData::ServiceRegistry. So, looking up services by their service URL is the
most exact method, but lookup by namespace is provided for convenience.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/odata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
