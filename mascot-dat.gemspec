# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mascot/dat/version"

Gem::Specification.new do |s|
  s.name        = "mascot-dat"
  s.version     = Mascot::DAT::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Angel Pizarro"]
  s.email       = ["angel@upenn.edu"]
  s.homepage    = "http://github.com/delagoya/mascot-dat"
  s.summary     = %q{Mascot DAT file format parser}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  s.add_development_dependency "rake"
  s.add_development_dependency "yard"
end
