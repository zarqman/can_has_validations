# Ensure an attribute is generally formatted as an email.
# eg: validates :user_email, email: true

require_relative 'hostname_validator'

module ActiveModel::Validations
  class EmailValidator < ActiveModel::EachValidator

    EMAIL_REGEXP       = /\A([a-z0-9._+-]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    SEGMENT_REGEXP     = /\A[a-z0-9+_-]+\z/i
    LABEL_REGEXP       = HostnameValidator::LABEL_REGEXP
    FINAL_LABEL_REGEXP = HostnameValidator::FINAL_LABEL_REGEXP

    def validate_each(record, attribute, value)
      unless email_valid?(value)
        record.errors.add(attribute, :invalid_email, options.merge(value: value))
      end
    end

    def email_valid?(value)
      recipient, domain = value.split('@', 2)
      is_valid = true

      recipient ||= ''
      is_valid &&= recipient.length <= 255
      is_valid &&= recipient !~ /\.\./
      is_valid &&= !recipient.starts_with?('.') 
      is_valid &&= !recipient.ends_with?('.') 
      recipient.split('.').each do |segment|
        is_valid &&= segment =~ SEGMENT_REGEXP
      end

      domain ||= ''
      if defined?(Addressable::IDNA)
        domain &&= Addressable::IDNA.to_ascii(domain)
      end
      labels = domain.split('.')
      is_valid &&= domain.length <= 255
      is_valid &&= domain !~ /\.\./
      is_valid &&= labels.size.in? 2..100
      labels.each_with_index do |label, idx|
        is_valid &&= label.length <= 63
        if idx+1==labels.size
          is_valid &&= label =~ FINAL_LABEL_REGEXP
        else
          is_valid &&= label =~ LABEL_REGEXP
        end
      end

      is_valid
    end

  end
end
