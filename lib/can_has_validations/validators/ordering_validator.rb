# Attribute ordering
#   Ensures one value is greater or lesser than another (set of) value(s).
#   Always skips over nil values; use :presence to validate those.
# eg: validates :start_at, :before=>:finish_at
#     validates :start_at, :before=>{:value_of=>:finish_at, :if=>... }
#     validates :finish_at, :after => [:start_at, :alt_start_at]
#     validates :finish_at, :after=>{:values_of => [:start_at, :alt_start_at], :if=>... }

module ActiveModel::Validations
  class BeforeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      compare_to = Array.wrap(options[:value_of] || options[:values_of] || options[:in] || options[:with])
      compare_to.each do |attr_name|
        greater = attr_name.call(record) if attr_name.respond_to?(:call)
        greater ||= record.send attr_name
        next unless value && greater
        unless value < greater
          attr2 = record.class.human_attribute_name attr_name
          record.errors.add(attribute, :before, options.except(:before).merge!(:attribute2=>attr2))
        end
      end
    end
  end
  class AfterValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      compare_to = Array.wrap(options[:value_of] || options[:values_of] || options[:in] || options[:with])
      compare_to.each do |attr_name|
        lesser = attr_name.call(record) if attr_name.respond_to?(:call)
        lesser ||= record.send attr_name
        next unless value && lesser
        unless value > lesser
          attr2 = record.class.human_attribute_name attr_name
          record.errors.add(attribute, :after, options.except(:after).merge!(:attribute2=>attr2))
        end
      end
    end
  end
end
