# CanHasValidations #

`can_has_validations` provides several additional validations for Rails and
ActiveModel.

Validations provided:

* Email
* Grandparent
* Ordering
* URL
* Write Once

All validators use the newer Rails 3 syntax:

    validates :some_attribute, :email=>true

(That is, there's not a validates_email_of :some_attribute helper.)


## Email ##

Ensures an attribute is generally formatted as an email. It uses a basic regex
that's designed to match something that looks like an email. It allows for any
TLD, so as to not fail as ICANN continues to add TLDs.

    validates :user_email, :email=>true


## Grandparent ##

Ensures two (or more) associations share a common parent value. 

`:allow_nil=>true` will not only allow the attribute/association to be nil, but
also any of the `:scope` values.

Consider a model tree like this:

    class User < ActiveRecord::Base
      has_many :addresses
      has_many :phones
    end
    
    class Address < ActiveRecord::Base
      belongs_to :user
      has_many :orders
    end
    
    class Phone < ActiveRecord::Base
      belongs_to :user
      has_many :orders
    end
    
    class Order < ActiveRecord::Base
      belongs_to :address
      belongs_to :phone
      
      validates :phone, :grandparent=>{:scope=>:address, :parent=>:user}
    end

For any `Order`, this ensures that both `:address` and `:phone` belong to the same
`:user`, even though `Order` doesn't directly have an association to `:user`.

Basically it starts with the attribute being validated (`:phone` in this case)
and the scoped attributes (just `:address` in this case, but you can supply an
array if needed, eg: `:scope=>[:billing_address, :mailing_address]` ). 

Then, it looks for the attribute that is the common parent (`:user` in the above
example). So, it's looking for `phone.user` and `address.user`. 

Finally, it's comparing those values to make sure they match. In this case, if
`phone.user` and `address.user` match, then the validation passes. If the phone and
address belong to different users, then the validation fails.

When the `:parent` value is an association, you can use the association (`:user`)
or the database foreign key (`:user_id`). You can also use any other field. The
test is merely that they match, not that they are associations.


## Ordering ##

Ensures two attribute values maintain a relative order to one another. This is
often useful when two date or range values. Validations can be written using
either `:before` or `:after` to make them readable.

Always skips over nil values; use `:presence` to validate those.

    # Short versions:
    validates :start_at, :before => :finish_at
    validates :finish_at, :after => [:start_at, :alt_start_at]
    validates :start_at, :presence => true, :before => :finish_at
    
    # Long versions, if you need to add extra validation options:
    validates :start_at, :before => {:value_of => :finish_at, :message=>"..." }
    validates :finish_at, :after => {:values_of => [:start_at, :alt_start_at], :if=>... }


## URL ##

Ensure an attribute is generally formatted as a URL. If `addressable/uri` is
already loaded, it will be used to parse IDN's.

    validates :website, :url=>true

    # With IDN parsing:
    require 'addressable/uri'
    validates :website, :url=>true


## Write Once ##

Ensure that once a value is written, it becomes readonly. There are two uses
for this. 

The first is as an equivalent to `attr_readonly :user_id` except that it also
produces a validation error instead of silently ignoring the change as
`attr_readonly` does.

    validates :user_id, :presence=>true, :write_once=>true

The second use is to allow an attribute to be nil when the record is first
created and allow it to be set once at some arbitrary point in the future, but
once set, still make it immutable. A WORM (write once, read many) attribute of
sorts.

    validates :user_id, :write_once=>true


## Error messages

Validation error messages are localized and can be added to your locale files.
Default messages are as follows:

    en:
      errors:
        messages:
          invalid_email: "is an invalid email"
          invalid_url: "is an invalid URL"
          unchangeable: "cannot be changed"
          before: "must be before %{attribute2}"
          after: "must be after %{attribute2}"


## Compatibility ##

Tested with Ruby 1.9 and ActiveSupport and ActiveModel 3.2.8+.
