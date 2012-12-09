# Attribute ordering
#   Ensures one value is greater or lesser than another (set of) value(s).
#   Always skips over nil values; use :presence to validate those.
# eg: validates :start_at, :ordering=>{:before => :finish_at }
#     validates :finish_at, :ordering=>{:after => [:start_at, :alt_start_at] }

class OrderingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Array(options[:before]).each do |attr_name|
      greater = record.send attr_name
      next unless value && greater
      unless value < greater
        record.errors[attribute] << (options[:message] || "must be before #{record.class.human_attribute_name attr_name}")
      end
    end
    Array(options[:after]).each do |attr_name|
      lesser = record.send attr_name
      next unless value && lesser
      unless value > lesser
        record.errors[attribute] << (options[:message] || "must be after #{record.class.human_attribute_name attr_name}")
      end
    end
  end
end
