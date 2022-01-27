$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "can_has_validations/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "can_has_validations"
  s.version     = CanHasValidations::VERSION
  s.authors     = ["thomas morgan"]
  s.email       = ["tm@iprog.com"]
  s.homepage    = "https://github.com/zarqman/can_has_validations"
  s.summary     = "Assorted Rails 5.x-7.x validators"
  s.description = "Assorted Rails 5.x-7.x validators: Array, Email, Existence, Grandparent, Hash keys, Hash values, Hostname, IP address, Ordering, URL, Write Once"
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 5.2", "< 7.1"

  s.add_development_dependency "rake"
  s.add_development_dependency "sqlite3"
end
