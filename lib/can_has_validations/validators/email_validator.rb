# Ensure an attribute is generally formatted as an email.
# eg: validates :user_email, email: true

module ActiveModel::Validations
  class EmailValidator < ActiveModel::EachValidator

    EMAIL_REGEXP = /\A([a-z0-9._+-]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

    def validate_each(record, attribute, value)
      unless value =~ EMAIL_REGEXP
        record.errors.add(attribute, :invalid_email, options)
      end
    end
  end
end
