# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rails_locale_sorter/version"

Gem::Specification.new do |s|
  s.name        = "rails_locale_sorter"
  s.version     = RailsLocaleSorter::VERSION
  s.authors     = ["Michael Wheeler"]
  s.email       = ["michael.wheeler@tapjoy.com"]
  s.homepage    = "http://github.com/matchboxmike"
  s.summary     = %q{Manage Rails Locale YAML: Sort, remove duplicates, and create stubs for other languages.}
  s.description = %q{Manage Rails Locale YAML: Sort, remove duplicates, and create stubs for other languages.}

  s.rubyforge_project = "rails_locale_sorter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_dependency "rubygems-update", ">= 1.3.7"
  s.add_dependency "activesupport", ">= 2.3.14"
  s.add_dependency "ya2yaml", ">= 0.30"
end
