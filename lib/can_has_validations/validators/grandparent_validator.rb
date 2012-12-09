# Ensure two (or more) associations share a common parent
#   :allow_nil will not only allow the attribute/association to be nil, but
#     also any of the :scope's.
# eg: validates :user, :grandparent=>{:scope=>:org, :parent=>:realm}
#     validates :user, :grantparent=>{:scope=>[:phone, :address], :parent=>:account_id}

class GrandparentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, association)
    all_match = Array(options[:scope]).all? do |scope|
      cousin = record.send(scope)
      if cousin.nil?
        options[:allow_nil]
      else
        association.send(options[:parent]) == cousin.send(options[:parent])
      end
    end
    record.errors[attribute] << (options[:message] || "is invalid") unless all_match
  end
end
