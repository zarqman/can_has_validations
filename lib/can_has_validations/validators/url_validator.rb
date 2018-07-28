# Ensure an attribute is generally formatted as a URL. If addressable/uri is
#   already loaded, will use it to parse IDN's.
# eg: validates :website, url: true
#     validates :redis, url: {scheme: 'redis'}
#     validates :database, url: {scheme: %w(postgres mysql)}

module ActiveModel::Validations
  class UrlValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      allowed_schemes = Array.wrap(options[:scheme] || %w(http https))

      if defined?(Addressable::URI)
        u = Addressable::URI.parse(value) rescue nil
        u2 = u && URI.parse(u.normalize.to_s) rescue nil
      else
        u2 = u = URI.parse(value) rescue nil
      end
      if !u || !u2 || u.relative? || allowed_schemes.exclude?(u.scheme)
        record.errors.add(attribute, :invalid_url, options.merge(value: value))
      end
    end
  end
end
