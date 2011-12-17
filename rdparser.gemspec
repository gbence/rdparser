require File.expand_path("../lib/rdparser/version", __FILE__)

Gem::Specification.new do |s|
  s.name              = "rdparser"
  s.version           = RDParser::VERSION
  s.platform          = Gem::Platform::RUBY
  s.authors           = ["Peter Cooper", "Bence Golda"]
  s.email             = ["golda@bitandpixel.hu"]
  s.homepage          = "http://www.rubyinside.com/recursive-descent-parser-for-ruby-300.html"
  s.summary           = "rdparser-#{RDParser::VERSION}"
  s.description       = "A Simple Recursive Descending (LL) Parser for Ruby"
  s.rubyforge_project = "rdparser"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "spork"
  s.add_development_dependency "watchr"

  s.files             = `git ls-files`.split("\n")
  s.executables       = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  #s.extra_rdoc_files  = [ "README.markdown" ]
  s.rdoc_options      = ["--charset=UTF-8"]
  s.require_path      = 'lib'
end

