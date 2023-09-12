# Ensure an attribute is generally formatted as a hostname/domain.
# What's validated and not:
#   max length of entire hostname is 255
#   max length of each label within the hostname is 63
#   characters allowed: a-z, A-Z, 0-9, hyphen
#   underscore is also allowed with allow_underscore: true
#   the final label must be a-z,A-Z or an IDN
#   labels may not begin with a hyphen
#   labels may not end with a hyphen or underscore
#   labels may be entirely numeric
#     note: this is more common that you think (reverse dns, etc)
# If the addressable gem is present, will automatically turn unicode domains
#   into their punycode (xn--) equivalent. Otherwise, unicode characters will
#   cause the validation to fail.
#
# eg: validates :domain, hostname: true
#     validates :domain, hostname: {allow_wildcard: true}
#       allows '*.example.com'
#     validates :domain, hostname: {allow_underscore: true}
#       allows '_abc.example.com'
#     validates :domain, hostname: {allow_slash: true}
#       allows '4.0/25.3.2.1.example.com'  # rfc2317
#     validates :domain, hostname: {segments: 3..100}
#       allows 'a.example.com', but not 'example.com'
#     validates :domain, hostname: {allow_ip: true}  # or 4 or 6 for ipv4 or ipv6 only
#       allows '1.2.3.4' or 'a.example.com'
#     validates :subdomain, hostname: {skip_tld: true}
#       allows 'subdomain1'; implies segments: 1..100 unless otherwise specified

require 'resolv'

module ActiveModel::Validations
  class HostnameValidator < ActiveModel::EachValidator

    LABEL_REGEXP = %r{\A([a-zA-Z0-9_]([a-zA-Z0-9_/-]+)?)?[a-zA-Z0-9]\z}
    FINAL_LABEL_REGEXP = %r{\A(xn--[a-zA-Z0-9]{2,}|[a-zA-Z]{2,})\z}
    RESERVED_OPTIONS = %i(allow_ip allow_slash allow_underscore allow_wildcard)

    def validate_each(record, attribute, value)
      value = value.to_s
      case options[:allow_ip]
      when 4, '4'
        return if value =~ Resolv::IPv4::Regex
      when 6, '6'
        return if value =~ Resolv::IPv6::Regex
      when true
        return if value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex
      end

      segments = options[:segments] || (options[:skip_tld] ? 1..100 : 2..100)
      segments = segments..segments if segments.is_a?(Integer)
      if defined?(Addressable::IDNA)
        value &&= Addressable::IDNA.to_ascii(value)
      end
      labels = value.split('.', -1)

      is_valid = true
      is_valid &&= value.length <= 255
      is_valid &&= value !~ /\.\./
      is_valid &&= value !~ /_/ unless options[:allow_underscore]
      is_valid &&= value !~ %r{/} unless options[:allow_slash]
      is_valid &&= labels.size.in? segments
      labels.each_with_index do |label, idx|
        is_valid &&= label.length <= 63
        if !options[:skip_tld] && idx+1==labels.size
          is_valid &&= label =~ FINAL_LABEL_REGEXP
        elsif options[:allow_wildcard]==:multi && idx==0
          is_valid &&= %w(** *).include?(label) || label =~ LABEL_REGEXP
        elsif options[:allow_wildcard] && idx==0
          is_valid &&= label=='*' || label =~ LABEL_REGEXP
        else
          is_valid &&= label =~ LABEL_REGEXP
        end
      end

      unless is_valid
        record.errors.add(attribute, :invalid_hostname, **options.except(*RESERVED_OPTIONS).merge!(value: value))
      end
    end

  end
end
