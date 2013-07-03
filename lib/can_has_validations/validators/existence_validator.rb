# Just like `presence` except that it properly ignores allow_nil / allow_blank.
# This is how Rails 3.2 worked, but was changed in Rails 4. Mongoid 3 and 4 both
#   act like Rails 4, so this is useful there too.

module ActiveModel::Validations
  class ExistenceValidator < ActiveModel::Validations::PresenceValidator
    def validate(record)
      attributes.each do |attribute|
        value = record.read_attribute_for_validation(attribute)
        validate_each(record, attribute, value)
      end
    end
  end  
end