%w(email existence grandparent hostname ordering url write_once).each do |validator|
  require "can_has_validations/validators/#{validator}_validator"
end


require 'active_support/i18n'
I18n.load_path << File.dirname(__FILE__) + '/can_has_validations/locale/en.yml'
