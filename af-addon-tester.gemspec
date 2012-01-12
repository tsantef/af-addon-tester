# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "af-addon-tester/version"

Gem::Specification.new do |s|
  s.name        = "af-addon-tester"
  s.version     = AppFog::AddonTester::VERSION
  s.default_executable = %q{af-addon-tester}
  s.authors     = ["Tim Santeford"]
  s.email       = ["tim@phpfog.com"]
  s.homepage    = ""
  s.summary     = %q{Tests App Fog Add-ons}
  s.description = %q{Allows developers to test App Fog add-ons}

  s.rubyforge_project = "af-addon-tester"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'json'
end
