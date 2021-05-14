require 'active_model/validations'

%w(array email existence grandparent hash_keys hash_values hostname ipaddr ordering url write_once).each do |validator|
  require "can_has_validations/validators/#{validator}_validator"
end


require 'active_support/i18n'
I18n.load_path << File.dirname(__FILE__) + '/can_has_validations/locale/en.yml'
