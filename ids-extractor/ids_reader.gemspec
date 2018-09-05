# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require './lib/version'

Gem::Specification.new do |s|
  s.name = %q{ids_reader}
  s.version = VERSION

  #s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Donald French"]
  s.date = %q{2018-03-22}    # original %q{2010-08-23}
  s.description = %q{pdf document reader}
  s.email = ["dhf@vertisoft.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt"]
  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.summary = %q{Separates reports and extracts defined information from each report}
  #s.add_dependency(%{activesupport})
  s.add_dependency(%q{andand}, ['~> 1.3'])
  s.add_dependency(%q{logging}, ['~> 2.2'])
  s.add_dependency(%q{rake}, ['~> 12.3'])

  s.add_dependency(%q{iconv}, ['~> 1.0'])
  s.add_dependency(%q{rghost}, ['~> 0.9.6'])
  s.add_dependency(%q{builder}, ['~> 3.2'])
  s.add_dependency(%q{json}, ['~> 2.1'])
  s.add_dependency(%{bunny})
  s.add_dependency(%{activerecord})
  s.add_dependency(%{pg})
  s.add_dependency(%{activesupport})
  #  s.add_dependency(%q{rubygems})
  s.add_development_dependency(%q{guard-rspec}) #, ['~> 4.7'])
  s.add_development_dependency(%q{guard-bundler}) #, ['~> 2.1'])
  s.add_development_dependency(%q{pry-byebug}) #, ["~> 3.5"])
  s.add_development_dependency(%q{rspec}) #, ['~> 3.7'])
  s.add_development_dependency(%q{machinist}) #, ['~> 2.0'])

end
