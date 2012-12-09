$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "can_has_validations/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "can_has_validations"
  s.version     = CanHasValidations::VERSION
  s.authors     = ["thomas morgan"]
  s.email       = ["tm@iprog.com"]
  s.homepage    = "http://iprog.com/projects"
  s.summary     = "Assorted Rails 3 validators"
  s.description = "Assorted Rails 3 validators."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_development_dependency "sqlite3"
end
