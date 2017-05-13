# write-once, read-many
#   Allows a value to be set to a non-nil value once, and then makes it immutable.
#   Combine with existence: true to accomplish the same thing as attr_readonly,
#   except with error messages (instead of silently refusing to save the change).
# eg: validates :user_id, write_once: true
#   Optionally refuses changing from nil => non-nil, always making field immutable.
# eg: validates :source, write_once: {immutable_nil: true}

module ActiveModel::Validations
  class WriteOnceValidator < ActiveModel::EachValidator
    # as of ActiveModel 4, allow_nil: true causes a change from a value back to
    #   nil to be allowed. prevent this.
    def validate(record)
      attributes.each do |attribute|
        value = record.read_attribute_for_validation(attribute)
        validate_each(record, attribute, value)
      end
    end

    def validate_each(record, attribute, value)
      if record.persisted? && record.send("#{attribute}_changed?")
        if options[:immutable_nil] || !record.send("#{attribute}_was").nil?
          record.errors.add(attribute, :unchangeable, options)
        end
      end
    end
  end
end
