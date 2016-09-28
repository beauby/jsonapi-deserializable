module JSONAPI
  module Deserializable
    class Validations
      def initialize(validation_type, &block)
        @validation_type = validation_type
        @hash = {
          @validation_type => {
            attributes: [],
            relationships: []
          },
          types: {
            relationships: {}
          }
        }
        instance_eval(&block)
      end

      def to_h
        @hash
      end

      private

      # Define whether the +id+ of the primary resource should be part of
      #   this list.
      def id
        validations_hash[:id] = true
      end

      # Define the allowed type for the primary resource.
      # @param [Symbol] value The value of the type.
      def type(value)
        types_hash[:primary] = Array(value)
      end

      # Define the allowed type for the primary resource.
      # @param [Array<Symbol>] values List of allowed values of the type.
      def types(values)
        types_hash[:primary] = values
      end

      # Define an attribute with given key.
      # @param [Symbol] key The key of the attribute in the payload.
      def attribute(key)
        validations_hash[:attributes] << key
      end

      # TODO(beauby): Decide whether type: 'users' / types: [...] is better.
      #
      # @overload has_one(key)
      #   Define a has_one relationship with given key.
      #   @param [Symbol] key The key of the relationship in the payload.
      #
      # @overload has_one(key, type)
      #   Define a has_one relationship with given key.
      #   @param [Symbol] key The key of the relationship in the payload.
      #   @param [Symbol] type The expected type of the relationship value.
      #
      # @overload has_one(key, types)
      #   Define a has_one relationship with given key.
      #   @param [Symbol] key The key of the relationship in the payload.
      #   @param [Array<Symbol>] type List of acceptable types for the
      #     relationship value.
      def has_many(key, types = nil)
        validations_hash[:relationships] << key
        types_hash[:relationships][key] = { kind: :has_many }
        return unless types
        types_hash[:relationships][key][:types] = Array(types)
      end

      # @overload has_one(key)
      #   Define a has_one relationship with given key.
      #   @param [Symbol] key The key of the relationship in the payload.
      #
      # @overload has_one(key, type)
      #   Define a has_one relationship with given key.
      #   @param [Symbol] key The key of the relationship in the payload.
      #   @param [Symbol] type The expected type of the relationship value.
      #
      # @overload has_one(key, types)
      #   Define a has_one relationship with given key.
      #   @param [Symbol] key The key of the relationship in the payload.
      #   @param [Array<Symbol>] type List of acceptable types for the
      #     relationship value.
      def has_one(key, types = nil)
        validations_hash[:relationships] << key
        types_hash[:relationships][key] = { kind: :has_one }
        return unless types
        types_hash[:relationships][key][:types] = Array(types)
      end

      def validations_hash
        @hash[@validation_type]
      end

      def types_hash
        @hash[:types]
      end
    end
  end
end
