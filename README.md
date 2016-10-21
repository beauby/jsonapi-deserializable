# jsonapi-deserializable
Ruby gem for deserializing [JSON API](http://jsonapi.org) payloads into custom
hashes.

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

### Resources

```ruby
class DeserializableCreatePost < JSONAPI::Deserializable::Resource
  type
  attribute :title
  attribute :date { |date| field date: DateTime.parse(date) }
  has_one :author do |rel|
    field author_id: (rel['data'] && rel['data']['id'])
    field author_type: (rel['data'] && rel['data']['type'])
  end
  has_many :comments do |rel|
    field comment_ids: rel['data'].map { |ri| ri['id'] }
    field comment_types: rel['data'].map do |ri|
      camelize(singularize(ri['type']))
    end
  end
end
```
Finally, build your hash from the deserializable resource:
```ruby
payload = {
  'data' => {
    'id' => '1',
    'type' => 'posts',
    'attributes' => {
      'title' => 'Title',
      'date' => '2016-01-10 02:30:00'
    },
    'relationships' => {
      'author' => {
        'data' => { 'type' => 'users', 'id' => '1337' }
      },
      'comments' => {
        'data' => [
          { 'type' => 'comments', 'id' => '123' },
          { 'type' => 'comments', 'id' => '234' },
          { 'type' => 'comments', 'id' => '345' }
        ]
      }
    }
  }
}

DeserializableCreateUser.(payload)
# => {
#      id: '1',
#      title: 'Title',
#      date: #<DateTime: 2016-01-10T02:30:00+00:00 ((2457398j,9000s,0n),+0s,2299161j)>,
#      author_id: '1337',
#      author_type: 'users',
#      comment_ids: ['123', '234', '345']
#      comment_types: ['Comment', 'Comment', 'Comment']
#    }
```

### Relationships

```
class DeserializablePostComments < JSONAPI::Deserializable::Relationship
  has_many do |rel|
    field comment_ids: rel['data'].map { |ri| ri['id'] }
    field comment_types: rel['data'].map do |ri|
      camelize(singularize(ri['type']))
    end
  end
end
```

## License

jsonapi-deserializable is released under the [MIT License](http://www.opensource.org/licenses/MIT).
