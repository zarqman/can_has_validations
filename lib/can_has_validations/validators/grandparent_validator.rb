# Ensure two (or more) associations share a common parent
#   :allow_nil will not only allow the attribute/association to be nil, but
#     also any of the :scope's.
# eg: validates :user, grandparent: {scope: :org, parent: :realm}
#     validates :user_id, grandparent: {scope: [:phone, :address], parent: :account_id}

module ActiveModel::Validations
  class GrandparentValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, association)
      # to allow attribute to be the _id and not just the actual association
      if attribute.to_s.ends_with?('_id')
        association = record.send(attribute.to_s.sub(/_id$/,''))
      end
      all_match = Array(options[:scope]).all? do |scope|
        cousin = record.send(scope)
        if cousin.nil?
          options[:allow_nil]
        else
          association &&
            association.send(options[:parent]) == cousin.send(options[:parent])
        end
      end
      unless all_match
        record.errors.add(attribute, :invalid, **options.except(:allow_nil, :parent, :scope))
      end
    end
  end
end
