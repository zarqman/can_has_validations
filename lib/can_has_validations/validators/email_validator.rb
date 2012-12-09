class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([a-z0-9._+-]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
      record.errors[attribute] << (options[:message] || "is not a valid email")
    end
  end
end
