# require 'uri'
# require 'addressable/uri'

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if defined?(Addressable::URI)
      u = Addressable::URI.parse(value) rescue nil
    else
      u = URI.parse(value) rescue nil
    end
    # %w(URI::HTTP URI::HTTPS).exclude?(u.class)
    if !u || u.relative? || %w(http https).exclude?(u.scheme)
      record.errors[attribute] << (options[:message] || "is not a valid URL")
    end
  end
end
