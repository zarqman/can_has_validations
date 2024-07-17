# Attribute ordering
#   Ensures one value is greater or lesser than another (set of) value(s).
#   The special value of :now will automatically become Time.now (without needing a lambda).
#   Always skips over nil values; use :presence to validate those.
# eg: validates :start_at, before: :finish_at
#     validates :start_at, before: {value_of: :finish_at, if: ... }
#     validates :finish_at, after: [:start_at, :now]
#     validates :finish_at, after: {values_of: [:start_at, :now], if: ... }

module ActiveModel::Validations
  class BeforeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      compare_to = Array.wrap(options[:value_of] || options[:values_of] || options[:in] || options[:with])
      compare_to.each do |attr_name|
        greater = attr_name.call(record) if attr_name.respond_to?(:call)
        greater ||= Time.now if attr_name==:now && !record.respond_to?(:now)
        greater ||= record.send attr_name
        next unless value && greater
        unless value < greater
          attr2 = attr_name.respond_to?(:call) ? 'it is' : record.class.human_attribute_name(attr_name)
          record.errors.add(attribute, :before, value:, attribute2: attr2, before_value: greater, **options.except(:before))
        end
      end
    end
  end
  class AfterValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      compare_to = Array.wrap(options[:value_of] || options[:values_of] || options[:in] || options[:with])
      compare_to.each do |attr_name|
        lesser = attr_name.call(record) if attr_name.respond_to?(:call)
        lesser ||= Time.now if attr_name==:now && !record.respond_to?(:now)
        lesser ||= record.send attr_name
        next unless value && lesser
        unless value > lesser
          attr2 = attr_name.respond_to?(:call) ? 'it is' : record.class.human_attribute_name(attr_name)
          record.errors.add(attribute, :after, value:, attribute2: attr2, after_value: lesser, **options.except(:after))
        end
      end
    end
  end
end
