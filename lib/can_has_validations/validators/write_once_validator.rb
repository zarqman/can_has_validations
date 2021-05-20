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
        validate_each(record, attribute, nil)
      end
    end

    def validate_each(record, attribute, _)
      return unless record.persisted?
      if !record.respond_to?("#{attribute}_changed?") && record.respond_to?("#{attribute}_id_changed?")
        attr2 = "#{attribute}_id"
      else
        attr2 = attribute
      end
      if record.send("#{attr2}_changed?")
        if options[:immutable_nil] || !record.send("#{attr2}_was").nil?
          value = record.read_attribute_for_validation(attribute)
          record.errors.add(attribute, :unchangeable, **options.except(:immutable_nil).merge!(value: value))
        end
      end
    end
  end
end
