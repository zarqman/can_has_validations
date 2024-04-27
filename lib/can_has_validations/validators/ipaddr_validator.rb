# Ensure an attribute is generally formatted as a IP or IP block.
# eg: validates :ip, ipaddr: true
#     validates :cidr, ipaddr: {allow_block: true}
#     validates :private_ip, ipaddr: {within: [IPAddr.new('10.0.0.0/8'), '127.0.0.1']}
#       ip must be within any one of the provided ips/blocks
#       if ip is block, it must be fully contained within any one of the provided blocks
#     validates :public_ip6, ipaddr: {without: ['fc00::/7']]}
#       ip must be outside all of the provided ips/blocks
#       if ip is block, it must be fully outside all of the provided blocks

require 'ipaddr'

module ActiveModel::Validations
  class IpaddrValidator < ActiveModel::EachValidator

    def initialize(options)
      options[:within]  = normalize_within options[:within], :within
      options[:without] = normalize_within options[:without], :without
      super
    end

    def validate_each(record, attribute, value)
      allowed_ips    = resolve_array record, options[:within]
      disallowed_ips = resolve_array record, options[:without]

      ip = case value
        when IPAddr
          ip
        when String
          IPAddr.new(value) rescue nil
      end
      unless ip
        record.errors.add(attribute, :invalid_ip, **options.merge(value: value))
        return
      end

      if !options[:allow_block] && (ip.ipv4? && ip.prefix!=32 or ip.ipv6? && ip.prefix!=128)
        record.errors.add(attribute, :single_ip_required, **options.merge(value: value))
      end
      if allowed_ips && allowed_ips.none?{|blk| ip_within_block? ip, blk}
        record.errors.add(attribute, :ip_not_allowed, **options.merge(value: value))
      elsif disallowed_ips && disallowed_ips.any?{|blk| ip_within_block? ip, blk}
        record.errors.add(attribute, :ip_not_allowed, **options.merge(value: value))
      end
    end


    private

    def ip_within_block?(ip, blk)
      return false unless ip.family == blk.family
      ip = ip.to_range
      blk = blk.to_range
      ip.begin >= blk.begin && ip.end <= blk.end
    end

    def normalize_within(val, key)
      if val.nil? || val.respond_to?(:call) || val.is_a?(Symbol)
        val
      else
        Array(val).flatten.map do |i|
          case i
          when IPAddr
            i
          when String
            IPAddr.new i
          else
            raise "Unexpected value for #{key.inspect} : #{i}"
          end
        end
      end
    end

    def resolve_array(record, val)
      if val.respond_to?(:call)
        val.call(record)
      elsif val.is_a?(Symbol)
        record.send(val)
      else
        val
      end
    end

  end
end
