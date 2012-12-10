# write-once, read-many
#   Allows a value to be set to a non-nil value once, and then makes it immutable.
#   Combine with :presence=>true to accomplish the same thing as attr_readonly,
#   except with error messages (instead of silently refusing to save the change).
# eg: validates :user_id, :write_once=>true

module ActiveModel::Validations
  class WriteOnceValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.persisted? && record.send("#{attribute}_changed?") && !record.send("#{attribute}_was").nil?
        record.errors.add(attribute, :unchangeable, options)
      end
    end
  end
end
