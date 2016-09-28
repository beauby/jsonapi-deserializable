require 'jsonapi/deserializable/exceptions'
require 'jsonapi/deserializable/relationship_dsl'

module JSONAPI
  module Deserializable
    class Relationship
      include RelationshipDSL

      class << self
        attr_accessor :field_blocks, :validations
      end

      self.field_blocks = {}
      self.validations = {}

      def self.inherited(klass)
        klass.field_blocks = field_blocks.dup
        klass.validations = Marshal.load(Marshal.dump(validations))
      end

      def initialize(payload)
        JSONAPI.validate_relationship!(payload, validations)
        @document = payload
        @data = payload['data']
      end

      def to_h
        return nil if @data.nil?
        return @_hash if @_hash
        @_hash = {}
        self.class.field_blocks.each do |key, block|
          @_hash[key] = instance_eval(&block)
        end
        @_hash
      end
    end
  end
end
