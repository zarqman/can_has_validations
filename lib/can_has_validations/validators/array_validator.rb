# validates each member element of an array attribute
#
# by default will allow only the first error per validator, regardless of how
# many elements might fail validation. this improves performance as well as
# averting a large number of repeating error messages.
# use  multiple_errors: true  on :array or a single sub-validator to enable the
# full set of errors. this is potentially useful if each error message will
# vary based upon the array element's contents.
#
# usage:
#   validates :tags,
#     array: {
#       format: /\A[^aeiou]*\z/,
#       length: 5..10
#     }
#
#   validates :permissions,
#     array: {
#       multiple_errors: true,
#       format: /\A[^aeiou]*\z/
#     }

module ActiveModel
  module Validations
    class ArrayValidator < ActiveModel::EachValidator
      attr_reader :validators

      def initialize(options)
        record_class = options[:class]
        super
        record_class.extend DefaultKeys

        defaults = @options.dup
        validations = defaults.slice!(*record_class.send(:_validates_default_keys), :attributes)

        raise ArgumentError, "You need to supply at least one array validation" if validations.empty?

        defaults[:attributes] = attributes

        @validators = validations.map do |key, sub_options|
          next unless sub_options
          key = "#{key.to_s.camelize}Validator"

          begin
            klass = key.include?("::".freeze) ? key.constantize : record_class.const_get(key)
          rescue NameError
            raise ArgumentError, "Unknown validator: '#{key}'"
          end

          klass.new(defaults.merge(_parse_validates_options(sub_options)))
        end
      end

      def validate_each(record, attribute, array_values)
        @validators.each do |validator|
          error_count = count_errors(record)

          Array(array_values).each do |value|
            validator.validate_each(record, attribute, value)

            # to avoid repeating error messages, stop after a single error
            unless validator.options[:multiple_errors]
              break if error_count != count_errors(record)
            end
          end
        end
      end


      private

      def count_errors(record)
        # more efficient than calling record.errors.size
        record.errors.messages.sum{|key, val| val.blank? ? 0 : val.size }
      end

      def _parse_validates_options(options)
        case options
        when TrueClass
          {}
        when Hash
          options
        when Range, Array
          { in: options }
        else
          { with: options }
        end
      end


      module DefaultKeys
        private

        # When creating custom validators, it might be useful to be able to specify
        # additional default keys. This can be done by overwriting this method.
        def _validates_default_keys
          super + [:multiple_errors]
        end
      end

    end

  end
end
