require 'jsonapi/deserializable/relationship_dsl'

module JSONAPI
  module Deserializable
    class Relationship
      include RelationshipDSL

      class << self
        attr_accessor :has_one_block, :has_many_block
      end

      def self.inherited(klass)
        klass.has_one_block  = has_one_block
        klass.has_many_block = has_many_block
      end

      def self.call(payload)
        new(payload).to_h
      end

      def initialize(payload)
        @document = payload
        @data = payload['data']
        deserialize!
      end

      def to_h
        @hash
      end

      private

      def deserialize!
        @hash = {}
        if @data.is_a?(Array)
          instance_exec(@document, &self.class.has_many_block)
        else
          instance_exec(@document, &self.class.has_one_block)
        end
      end

      def field(hash)
        @hash.merge!(hash)
      end
    end
  end
end
