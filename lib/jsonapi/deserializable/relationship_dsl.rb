module JSONAPI
  module Deserializable
    module RelationshipDSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def has_one
          validations[:kind] = :has_one
        end

        def has_many
          validations[:kind] = :has_many
        end

        def type(value)
          (validations[:types] ||= []) << value
        end

        def types(values)
          (validations[:types] ||= []).concat(values)
        end

        def field(key, &block)
          field_blocks[key] = block
        end
      end
    end
  end
end
