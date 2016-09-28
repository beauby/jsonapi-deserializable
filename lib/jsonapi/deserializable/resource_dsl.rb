require 'jsonapi/deserializable/validations'

module JSONAPI
  module Deserializable
    module ResourceDSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def required(&block)
          add_validations!(Validations.new(:required, &block).to_h)
        end

        def optional(&block)
          add_validations!(Validations.new(:optional, &block).to_h)
        end

        def field(key, &block)
          field_blocks[key] = block
        end

        def id
          field(:id) { @data['id'] }
        end

        def attribute(key, opts = {})
          hash_key = (opts[:key] || key).to_s
          field(key) { @attributes[hash_key] }
        end

        def has_many_ids(key, opts = {})
          hash_key = (opts[:key] || key).to_s
          field(key) do
            @relationships[hash_key]['data'].map { |ri| ri['id'] }
          end
        end

        def has_many_types(key, opts = {})
          hash_key = (opts[:key] || key).to_s
          field(key) do
            @relationships[hash_key]['data'].map { |ri| ri['type'] }
          end
        end

        def has_one_id(key, opts = {})
          hash_key = (opts[:key] || key).to_s
          field(key) { @relationships[hash_key]['data']['id'] }
        end

        def has_one_type(key, opts = {})
          hash_key = (opts[:key] || key).to_s
          field(key) { @relationships[hash_key]['data']['type'] }
        end

        private

        def add_validations!(hash)
          validations[:permitted] = hash[:permitted] if hash[:permitted]
          validations[:required] = hash[:required] if hash[:required]
          return unless hash[:types]
          validations[:types] ||= {}
          if hash[:types][:primary]
            validations[:types][:primary] = hash[:types][:primary]
          end
          return unless hash[:types][:relationships]
          validations[:types][:relationships] ||= {}
          validations[:types][:relationships]
            .merge!(hash[:types][:relationships])
        end
      end
    end
  end
end
