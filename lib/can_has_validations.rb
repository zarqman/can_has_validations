require 'active_model/validations'

%w(array email existence grandparent hash_keys hash_values hostname ipaddr ordering url write_once).each do |validator|
  require "can_has_validations/validators/#{validator}_validator"
end


require 'active_support/i18n'
Dir[File.join(__dir__, 'can_has_validations', 'locale', '*.yml')].each do |fn|
  I18n.load_path << fn
end
