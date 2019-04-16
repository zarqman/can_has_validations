# CanHasValidations #

`can_has_validations` provides several additional validations for Rails and
ActiveModel.

Validations provided:

* Array
* Email
* Existence
* Grandparent
* Hostname
* Ordering
* URL
* Write Once

All validators use the newer Rails 3+ syntax:

    validates :some_attribute, email: true

(That is, there's not a validates_email_of :some_attribute helper.)


## Installation ##

Add it to your `Gemfile`:

    gem 'can_has_validations'




## Array validator ##

Many database engines allow for arrays of attributes. This validates each
member element of those arrays.

It is able to use most existing validators that themselves work on individual
attribute values (including standard Rails validators, others that are part of
this gem, and likely many from other gems too).

By default, it will stop validation of an array attribute after the first error
per validator, regardless of how many elements might fail validation. This both
improves performance as well as avoids producing a large number of duplicate
error messages. Add `multiple_errors: true` on `:array` or any individual
sub-validator to instead return all errors (useful if each error message will
vary based on the element's value).

    validates :tags,
      array: {
        format: /\A[^aeiou]*\z/,
        length: 5..10
      }

    validates :permissions,
      array: {
        multiple_errors: true,
        format: /\A[^aeiou]*\z/
      }


## Email validator ##

Ensures an attribute is generally formatted as an email. It uses a basic regex
that's designed to match something that looks like an email. It allows for any
TLD, so as to not fail as ICANN continues to add TLDs.

    validates :user_email, email: true


## Existence validator ##

Rails 4 changed the default behavior of the Presence validator. In Rails 3.x,
it always validated presence, even if `allow_nil: true` or `allow_blank: true`
was set. The Rails 4 Presence validator now acts on `allow_nil` and
`allow_blank`, which makes it semi-useless.

The Existence validator restores the previous behavior (but with a new name to
avoid any potential conflicts).

Mongoid 3 and 4 also exhibit the same behavior as Rails 4, even under Rails 3,
so this is useful with Mongoid as well.

    validates :name, existence: true


## Grandparent validator ##

Ensures two (or more) associations share a common parent value. 

`allow_nil: true` will not only allow the attribute/association to be nil, but
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
      
      validates :phone, grandparent: {scope: :address, parent: :user}
    end

For any `Order`, this ensures that both `:address` and `:phone` belong to the same
`:user`, even though `Order` doesn't directly have an association to `:user`.

Basically it starts with the attribute being validated (`:phone` in this case)
and the scoped attributes (just `:address` in this case, but you can supply an
array if needed, eg: `scope: [:billing_address, :mailing_address]` ). 

Then, it looks for the attribute that is the common parent (`:user` in the above
example). So, it's looking for `phone.user` and `address.user`. 

Finally, it's comparing those values to make sure they match. In this case, if
`phone.user` and `address.user` match, then the validation passes. If the phone and
address belong to different users, then the validation fails.

When the `:parent` value is an association, you can use the association (`:user`)
or the database foreign key (`:user_id`). You can also use any other field. The
test is merely that they match, not that they are associations.


## Hostname validator ##

Ensures an attribute is generally formatted as a hostname. It allows for any
TLD, so as to not fail as ICANN continues to add TLDs.

    validates :domain, hostname: true

    # allows '*.example.com'
    validates :domain, hostname: {allow_wildcard: true}

    # allows '_abc.example.com'
    validates :domain, hostname: {allow_underscore: true}

    # allows 'a.example.com', but not 'example.com'
    validates :domain, hostname: {segments: 3..100}

    # allows 'subdomain'
    validates :subdomain, hostname: {segments: 1, skip_tld: true}

    # allows '1.2.3.4' or 'a.example.com'
    validates :domain, hostname: {allow_ip: true}
    # use 4 or 6 for ipv4 or ipv6 only


## Ordering validators ##

Ensures two attribute values maintain a relative order to one another. This is
often useful when two date or range values. Validations can be written using
either `:before` or `:after` to make them readable. The special value of `:now`
will automatically become Time.now (without needing a lambda).


Always skips over nil values; use `:presence` to validate those.

    # Short versions:
    validates :start_at, before: :finish_at
    validates :finish_at, after: [:start_at, :alt_start_at]
    validates :start_at, presence: true, before: :finish_at
    # These two are the same, except `:now` produces a clearer error message:
    validates :finish_at, after: :now
    validates :finish_at, after: ->(r){ Time.now }
    
    # Long versions, if you need to add extra validation options:
    validates :start_at, before: {value_of: :finish_at, message: "..." }
    validates :finish_at, after: {values_of: [:start_at, :alt_start_at], if: ... }


## URL validator ##

Ensure an attribute is generally formatted as a URL. If `addressable/uri` is
already loaded, it will be used to parse IDN's. Additionally, allowed schemes
can be specified; they default to ['http','https'].

    validates :website, url: true
    validates :secure_url, url: {scheme: 'https'}

    # Dynamic list of schemes. *Must* return an array.
    validates :git, url: {scheme: :some_method}
    validates :old_school, url: {scheme: ->(record){ %w(ftp gopher) }}

    # With IDN parsing:
    require 'addressable/uri'
    validates :website, url: true

    # Or, as part of your Gemfile:
    gem 'addressable'
    gem 'can_has_validations'


## Write Once validator ##

Ensure that once a value is written, it becomes readonly. There are two uses
for this. 

The first is as an equivalent to `attr_readonly :user_id` except that it also
produces a validation error instead of silently ignoring the change as
`attr_readonly` does.

    validates :user_id, presence: true, write_once: true

The second use is to allow an attribute to be nil when the record is first
created and allow it to be set once at some arbitrary point in the future, but
once set, still make it immutable. A WORM (write once, read many) attribute of
sorts.

    validates :user_id, allow_nil: true, write_once: true


## Error messages

Validation error messages are localized and can be added to your locale files.
Default messages are as follows:

    en:
      errors:
        messages:
          invalid_email: "is an invalid email"
          invalid_hostname: "is an invalid hostname"
          invalid_url: "is an invalid URL"
          unchangeable: "cannot be changed"
          before: "must be before %{attribute2}"
          after: "must be after %{attribute2}"


## Compatibility ##

The current version is tested with Ruby 2.5-2.6 and ActiveModel 5.2-6.0.
