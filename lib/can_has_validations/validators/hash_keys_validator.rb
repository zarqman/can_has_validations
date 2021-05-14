# validates each key of a hash attribute
#
# by default only allows the first error per validator, regardless of how many
# keys fail validation. this improves performance and avoids a bunch of
# repeating error messages.
# use `multiple_errors: true` on :hash_keys or a single sub-validator to
# enable the full set of errors. this is potentially useful if each error
# message will vary based upon each hash key.
#
# the :if, :unless, and :on conditionals are not supported on sub-validators,
# but do work as normal on the :hash_keys validator itself.
#
# usage:
#   validates :subjects,
#     hash_keys: {
#       format: /\A[a-z]+\z/,
#       # multiple_errors: true
#     }

module ActiveModel
  module Validations
    class HashKeysValidator < ArrayValidator

      def validate_each(record, attribute, hash)
        super(record, attribute, Hash(hash).keys)
      end

    end
  end
end
