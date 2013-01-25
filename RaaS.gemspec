# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'RaaS/version'

Gem::Specification.new do |s|
  s.name = 'RaaS'
  s.version = RaaS::VERSION
  s.date = '2013-01-25'
  s.summary = "todo"
  s.description = "todo"
  s.authors = ["Peter Graham"]
  s.email = ["pete@gigadrill.com"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  s.homepage = 'http://github.com/6/RaaS-gem'

  s.add_dependency "andand"
  s.add_dependency "activesupport"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
end
