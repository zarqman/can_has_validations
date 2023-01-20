# Ensure an attribute is generally formatted as a URL. If addressable/uri is
#   already loaded, will use it to parse IDN's.
# eg: validates :website, url: true
#     validates :redis, url: {scheme: 'redis'}
#     validates :database, url: {scheme: %w(postgres mysql)}
#     validates :website, url: {host: 'example.com'}
#     validates :database, url: {port: [5432, nil]}
#       to allow scheme's default port, must specify `nil` too
# :scheme defaults to `%w(http https)`
# :host defaults to `nil` which allows any
# :port defaults to `nil` which allows any
#   to require blank, use `port: false` or `port: [nil]`

module ActiveModel::Validations
  class UrlValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if defined?(Addressable::URI)
        u = Addressable::URI.parse(value) rescue nil
        u2 = u && URI.parse(u.normalize.to_s) rescue nil
      else
        u2 = u = URI.parse(value) rescue nil
      end

      allowed_schemes =
        if options[:scheme].respond_to?(:call)
          options[:scheme].call(record)
        elsif options[:scheme].is_a?(Symbol)
          record.send(options[:scheme])
        else
          Array.wrap(options[:scheme] || %w(http https))
        end

      allowed_hosts =
        if options[:host].respond_to?(:call)
          options[:host].call(record)
        elsif options[:host].is_a?(Symbol)
          record.send(options[:host])
        elsif options[:host].nil?
          [u&.host]
        else
          Array.wrap(options[:host])
        end

      allowed_ports =
        if options[:port].respond_to?(:call)
          options[:port].call(record)
        elsif options[:port].is_a?(Symbol)
          record.send(options[:port])
        elsif options[:port].nil?
          [u&.port]
        elsif options[:port] == false
          [nil]
        else
          Array.wrap(options[:port])
        end

      if !u || !u2 || u.relative? || allowed_schemes.exclude?(u.scheme) || allowed_hosts.exclude?(u.host) || allowed_ports.exclude?(u.port)
        record.errors.add(attribute, :invalid_url, **options.merge(value: value, scheme: allowed_schemes, host: allowed_hosts, port: allowed_ports))
      end
    end
  end
end
