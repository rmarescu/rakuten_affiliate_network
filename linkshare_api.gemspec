 # -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "linkshare_api/version"

Gem::Specification.new do |s|
  s.name                  = "linkshare_api"
  s.version               = LinkshareAPI::VERSION
  s.authors               = ["Razvan Marescu"]
  s.email                 = ["razvan@marescu.net"]
  s.description           = %q{Ruby wrapper for LinkShare Publisher Web Services. See https://rakutenlinkshare.zendesk.com.}
  s.summary               = %q{Linkshare API}
  s.homepage              = "https://github.com/rmarescu/linkshare_api"
  s.license               = "MIT"
  s.required_ruby_version = ">= 1.9"

  s.files                 = `git ls-files`.split($/)
  s.test_files            = s.files.grep(%r{^(test|s|features)/})
  s.executables           = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.require_paths         = ["lib"]

  s.add_dependency "addressable", "~> 2.3"
  s.add_dependency "formatador", "~>0.2"
  s.add_dependency "httparty", "~> 0.13"
  s.add_dependency "recursive-open-struct", "~> 0.5"

  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake"
  s.add_development_dependency "webmock"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "guard-test"
  s.add_development_dependency "pry"
end
