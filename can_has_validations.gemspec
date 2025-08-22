$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "can_has_validations/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "can_has_validations"
  spec.version     = CanHasValidations::VERSION
  spec.authors     = ["thomas morgan"]
  spec.email       = ["tm@iprog.com"]
  spec.homepage    = "https://github.com/zarqman/can_has_validations"
  spec.summary     = "Assorted Rails 7.x-8.x validators"
  spec.description = "Assorted Rails 7.x-8.x validators: Array, Email, Existence, Grandparent, Hash keys, Hash values, Hostname, IP address, Ordering, URL, Write Once"
  spec.license     = 'MIT'

  spec.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]
  spec.test_files = Dir["test/**/*"]

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'rails', '>= 7.0'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'sqlite3'
end
