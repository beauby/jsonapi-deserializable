require 'jsonapi/deserializable/field_list'

module JSONAPI
  module Deserializable
    class DocumentValidator
      def self.validate!(payload, required_list, optional_list)
        new(payload, required_list, optional_list).validate!
      end

      def initialize(document, required, optional)
        whitelist = {
          id: :optional,
          types: [],
          attributes: {
            foo: :required,
            bar: :optional
          },
          relationships: {
            foobar: :required,
            barfoo: {
              required: true,
              types: [:baz],
              arity: :to_many
            }
          }
        }


        arities = {
          foobar: :to_many,
          barfoo: :to_one
        }
        types = {
          primary: [],
          relationships: {
            foobar: [:baz],
            barfoo: [:bazbaz]
          }
        }
              required: true,
              types: [:baz],
              arity: :to_many
            }
          }
        }
        @document = document
        @required = required || {}
        @optional = optional
        @fields = {}
        @fields[:primary_id] = true if @required[:primary_id]
        primary_types = @required[:primary_types]
        @fields[:primary_types] = primary_types if primary_types
        @fields[:attributes] = @required[:attributes].dup
        @fields[:relationships] = @required[:relationships].dup
        if @optional
          @fields[:primary_id] = true if @optional[:primary_id]
          primary_types = @optional[:primary_types]
          @fields[:primary_types] = primary_types if primary_types
          @fields[:attributes].merge
        end
      end

      def validate!
        raise INVALID_DOCUMENT unless @document.data
        @data = @document.data
        if @data.respond_to?(:each)
          raise INVALID_DOCUMENT, 'The request MUST include a single resource' \
                                  ' object as primary data'
        end
        @attributes = @data.attributes
        @relationships = @data.relationships
        validate_primary!
        validate_fields!
      end

      def validate_primary!
        validate_id!
        validate_type!
      end

      def id_required?
        @required[:primary_id]
      end

      def id_permitted?
        @fields[:primary_id]
      end

      def validate_id!
        if @data.id.nil?
          raise INVALID_DOCUMENT,
                'Expected id for primary resource' if id_required?
        else
          raise INVALID_DOCUMENT,
                'Unexpected id for primary resource' unless id_permitted?
        end
      end

      def type_valid?
        return false if @required &&
                        @required[:primary_types] &&
                        !@required[:primary_types].include?(@data.type.to_sym)
        return false if @optional &&
                        @optional[:primary_types] &&
                        !@optional[:primary_types].include?(@data.type.to_sym)
        true
      end

      def validate_type!
        return if type_valid?
        raise INVALID_DOCUMENT,
              "Unexpected type #{@data.type} for primary resource"
      end

      def validate_fields!
        validate_attributes!
        validate_relationships!
      end

      def attr_permitted?(attr_key)
        return true unless @optional
        return true if @optional[:attributes].include?(attr_key.to_sym)
        @required && @required[:attributes].include?(attr_key.to_sym)
      end

      def validate_attributes!
        @attributes.keys.each do |attr_key|
          next if attr_permitted?(attr_key)
          raise INVALID_DOCUMENT, "Unexpected attribute #{attr_key}"
        end
        return unless @required
        @required[:attributes].each do |attr_key|
          next if @attributes.defined?(attr_key)
          raise INVALID_DOCUMENT, "Expected attribute #{attr_key}"
        end
      end

      def rel_permitted?(rel_key)
        return true unless @optional
        return true if @optional[:relationships].key?(rel_key.to_sym)
        @required && @required[:relationships].key?(rel_key.to_sym)
      end

      def validate_relationships!
        @relationships.keys.each do |rel_key|
          next if rel_permitted?(rel_key)
          raise INVALID_DOCUMENT, "Unexpected relationship #{rel_key}"
        end
        return unless @required
        @required[:relationships].keys.each do |rel_key|
          next if @relationships.defined?(rel_key)
          raise INVALID_DOCUMENT, "Expected relationship #{rel_key}"
        end
        validate_relationship_types!
      end

      def validate_relationship_types!
        rels = {}
        rels.merge!(@required.relationships) if @required
        rels.merge(@optional.relationships) if @optional
        rels.each do |key, hash|
          rel = @relationships[key.to_s]
          unless rel.data
            raise INVALID_DOCUMENT, "Expected data for relationship #{key}"
          end

          if hash[:arity] == :to_one
            validate_to_one_relationship_type!(rel, hash[:types])
          else
            validate_to_many_relationship_type!(rel, hash[:types])
          end
        end
      end

      def validate_to_one_relationship_type!(rel, types)
        if rel.collection?
          raise INVALID_DOCUMENT,
                "Expected relationship #{key} to be has_one"
        end
        return unless types && !types.include?(rel.data.type.to_sym)
        raise INVALID_DOCUMENT, "Unexpected type: #{rel.data.type} for " \
                                "relationship #{key}"
      end

      def validate_to_many_relationship_type!(rel, types)
        unless rel.collection?
          raise INVALID_DOCUMENT,
                "Expected relationship #{key} to be has_many"
        end
        return unless types
        rel.data.each do |ri|
          unless types.include?(ri.type.to_sym)
            raise INVALID_DOCUMENT, "Unexpected type: #{ri.type} for " \
                                    "relationship #{key}"
          end
        end
      end
    end
  end
end
