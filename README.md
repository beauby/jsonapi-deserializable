# jsonapi-deserializable
Ruby gem for validating and deserializing [JSON API](http://jsonapi.org)
payloads into custom hashes.
Built upon the [jsonapi-validations](https://github.com/beauby/jsonapi/tree/master/validations)
gem.

## Status

[![Gem Version](https://badge.fury.io/rb/jsonapi-deserializable.svg)](https://badge.fury.io/rb/jsonapi-deserializable)
[![Build Status](https://secure.travis-ci.org/beauby/jsonapi-deserializable.svg?branch=master)](http://travis-ci.org/beauby/jsonapi-deserializable?branch=master)

## Installation
```ruby
# In Gemfile
gem 'jsonapi-deserializable'
```
then
```
$ bundle
```
or manually via
```
$ gem install jsonapi-deserializable
```

## Usage

First, require the gem:
```ruby
require 'jsonapi/deserializable'
```

Then, define some resource/relationship classes:
```ruby
class DeserializableUser < JSONAPI::Deserializable::Resource
  # List of required attributes / has_many/has_one relationships.
  #   This directive is not mandatory. If not declared, no field
  #   will be required.
  required do
    id # Optional, require an id for the primary resource.

    type :users # Optional, force a type for the primary resource.
    # or, still optional, force a set of allowed types for the primary resource:
    types [:users, :superusers] # Optional,

    attribute :name
    has_one :sponsor
    # or, optionally, spcecify a type for the relationship target:
    has_one :sponsor, :users
  end

  # List of optional attributes / has_many/has_one relationships.
  #   This directive is not mandatory. If not declared, all fields
  #   will be allowed. If declared, all fields that are not within
  #   eitheroptional or required will be rejected.
  optional do
    attribute :address
    has_many :posts
    # or, optionally, specify a set of allowed types for the primary resource:
    has_many :posts, [:posts, :blogs]
  end

  ## The actual fields of the generated hash.
  # `attribute` is a shorthand for `field(key) { @attributes.send(key) }`.
  attribute :address

  field :id do
    @data.id
  end

  # `field` is the standard method for defining a key on the result hash.
  field :username do
    @document.data.attributes.name
  end

  field :post_ids do
    @relationships.posts.data.map(&:id)
  end

  field :sponsor_id do
    @relationships.sponsor.data && @relationships.sponsor.data.id
  end
end
```
Finally, build your hash from the deserializable resource:
```ruby
payload = {
  'data' => {
    'id' => '1',
    'type' => 'users',
    'attributes' => {
      'name' => 'Name',
      'address' => 'Address'
    },
    'relationships' => {
      'sponsor' => {
        'data' => { 'type' => 'users', 'id' => '1337' }
      },
      'posts' => {
        'data' => [
          { 'type' => 'posts', 'id' => '123' },
          { 'type' => 'posts', 'id' => '234' },
          { 'type' => 'posts', 'id' => '345' }
        ]
      }
    }
  }
}

DeserializableUser.new(payload).to_h
# => {
#      username: 'Name',
#      address: 'Address',
#      sponsor_id: '1337',
#      post_ids: ['123', '234', '345']
#    }
```

## License

jsonapi-deserializable is released under the [MIT License](http://www.opensource.org/licenses/MIT).
