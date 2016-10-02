require 'jsonapi/validations'
require 'jsonapi/deserializable/exceptions'
require 'jsonapi/deserializable/resource_dsl'

module JSONAPI
  module Deserializable
    class Resource
      include ResourceDSL

      class << self
        attr_accessor :field_blocks, :validations
      end

      self.field_blocks = {}
      self.validations = {}

      def self.inherited(klass)
        super
        klass.field_blocks = field_blocks.dup
        klass.validations = Marshal.load(Marshal.dump(validations))
      end

      def initialize(payload)
        JSONAPI.validate_resource!(payload, self.class.validations)
        @document = payload
        @data = @document['data']
        @attributes = @data['attributes']
        @relationships = @data['relationships']
      end

      def to_h
        return @_hash if @_hash

        @_hash = {}
        @_hash[:_payload] = @document
        self.class.field_blocks.map do |k, v|
          @_hash[k] = instance_eval(&v)
        end

        @_hash
      end
    end
  end
end
