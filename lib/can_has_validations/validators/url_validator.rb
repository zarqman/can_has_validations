# Ensure an attribute is generally formatted as a URL. If addressable/uri is
#   already loaded, will use it to parse IDN's.
# eg: validates :website, :url=>true

module ActiveModel::Validations
  class UrlValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if defined?(Addressable::URI)
        u = Addressable::URI.parse(value) rescue nil
        u2 = u && URI.parse(u.normalize.to_s) rescue nil
      else
        u2 = u = URI.parse(value) rescue nil
      end
      if !u || !u2 || u.relative? || %w(http https).exclude?(u.scheme)
        record.errors.add(attribute, :invalid_url, options)
      end
    end
  end
end
