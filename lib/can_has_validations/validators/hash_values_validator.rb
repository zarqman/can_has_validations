# validates each value of a hash attribute
#
# by default only allows the first error per validator, regardless of how many
# values fail validation. this improves performance and avoids a bunch of
# repeating error messages.
# use `multiple_errors: true` on :hash_values or a single sub-validator to
# enable the full set of errors. this is potentially useful if each error
# message will vary based upon each hash value.
#
# the :if, :unless, and :on conditionals are not supported on sub-validators,
# but do work as normal on the :hash_values validator itself.
#
# usage:
#   validates :subjects,
#     hash_values: {
#       length: 3..100,
#       # multiple_errors: true
#     }

module ActiveModel
  module Validations
    class HashValuesValidator < ArrayValidator

      def initialize(options)
        record_class = options[:class]
        super
        record_class.include HashValidatorKey
      end

      def validate_each(record, attribute, hash)
        super(record, attribute, Array(Hash(hash)))
      end

      def validate_one(validator, record, attribute, key_and_value)
        key, value = key_and_value
        record.hash_validator_key = key
        super(validator, record, attribute, value)
      ensure
        record.hash_validator_key = nil
      end


      module HashValidatorKey
        def hash_validator_key
          @_hash_validator_key
        end

        def hash_validator_key=(v)
          @_hash_validator_key = v
        end
      end

    end
  end
end
