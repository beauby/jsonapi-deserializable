require 'jsonapi/deserializable'

describe JSONAPI::Deserializable::Resource, '#to_h' do
  before(:all) do
    @payload = {
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
  end

  it 'succeeds ensuring presence of id when present' do
    deserializable_klass = Class.new(JSONAPI::Deserializable::Resource) do
      required do
        id
      end
    end

    actual = deserializable_klass.new(@payload).to_h
    expected = {}

    expect(actual[:_payload]).to eq(@payload)
    actual.delete(:_payload)
    expect(actual).to eq(expected)
  end

  it 'fails ensuring presence of id when absent' do
    deserializable_klass = Class.new(JSONAPI::Deserializable::Resource) do
      required do
        id
      end
    end

    payload = {
      'data' => { 'type' => 'users' }
    }

    expect { deserializable_klass.new(payload) }
      .to raise_error(JSONAPI::Deserializable::INVALID_DOCUMENT)
  end

  it 'handles attributes as fields' do
    deserializable_klass = Class.new(JSONAPI::Deserializable::Resource) do
      field(:username) { @attributes['name'] }
      field(:address) { @attributes['address'] }
    end

    actual = deserializable_klass.new(@payload).to_h
    expected = {
      username: 'Name',
      address: 'Address'
    }

    expect(actual[:_payload]).to eq(@payload)
    actual.delete(:_payload)
    expect(actual).to eq(expected)
  end

  it 'handles relationships as fields' do
    deserializable_klass = Class.new(JSONAPI::Deserializable::Resource) do
      field(:sponsor_id) { @relationships['sponsor']['data']['id'] }
      field(:post_ids) { @relationships['posts']['data'].map { |ri| ri['id'] } }
    end

    actual = deserializable_klass.new(@payload).to_h
    expected = {
      sponsor_id: '1337',
      post_ids: %w(123 234 345)
    }

    expect(actual[:_payload]).to eq(@payload)
    actual.delete(:_payload)
    expect(actual).to eq(expected)
  end

  it 'works' do
    deserializable_klass = Class.new(JSONAPI::Deserializable::Resource) do
      required do
        type :users
        id
        attribute :name
        has_one :sponsor, [:users, :superusers]
      end

      optional do
        attribute :address
        has_many :posts, :posts
      end

      id
      attribute :address
      attribute :username, key: :name
      has_many_ids :post_ids, key: :posts
      has_one_id :sponsor_id, key: :sponsor
    end

    actual = deserializable_klass.new(@payload).to_h
    expected = {
      id: '1',
      username: 'Name',
      address: 'Address',
      sponsor_id: '1337',
      post_ids: %w(123 234 345)
    }

    expect(actual[:_payload]).to eq(@payload)
    actual.delete(:_payload)
    expect(actual).to eq(expected)
  end
end
