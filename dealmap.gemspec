# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dealmap/version"

Gem::Specification.new do |s|
  s.name        = "dealmap"
  s.version     = Dealmap::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Deeden"]
  s.email       = ["jdeeden@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Quick and dirty DealMap API client}
  s.description = %q{A very simple client for the DealMap API}

  s.rubyforge_project = "dealmap"
  s.add_development_dependency('rake', '~> 0.8')
  s.add_development_dependency('rspec', '~> 2.5')
  s.add_development_dependency('simplecov', '~> 0.4')
  s.add_development_dependency('vcr', '~> 1.7.0')
  s.add_development_dependency('fakeweb')
  s.add_development_dependency('yard', '~> 0.6')
  s.add_runtime_dependency("faraday", '~> 0.5.7')
  s.add_runtime_dependency("typhoeus", '~> 0.2.4')
  s.add_runtime_dependency('nokogiri', '~> 1.4')
  s.add_runtime_dependency('hashie', '~> 1.0.0')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
