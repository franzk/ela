# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ela/version"

Gem::Specification.new do |spec|
  spec.name          = "ela"
  spec.version       = ELA::VERSION
  spec.authors       = ["Franz Kißig"]
  spec.email         = ["fkissig@velalu.qa"]

  spec.summary       = %q{HTML5 E-Learning Framework}
  spec.homepage      = "https://github.com/velaluqa/ela.js"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #if spec.respond_to?(:metadata)
  #  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  #else
  #  raise "RubyGems 2.0 or newer is required to protect against " \
  #    "public gem pushes."
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|screenshots)/})
  end + `find node_modules dist -type f -print0`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.13"
  spec.add_dependency "sinatra", "~> 1.4", ">= 1.4.8"
  spec.add_dependency "sinatra-assetpack", "~> 0.3", ">= 0.3.5"
  spec.add_dependency "sinatra-backbone-2", "~> 0.1", ">= 0.1.1"
  spec.add_dependency "guard", "~> 2.10"
  spec.add_dependency "guard-compat", "~> 1.2", ">= 1.2.1"
  spec.add_dependency "guard-rack", "~> 2.2", ">= 2.2.0"
  spec.add_dependency "guard-livereload", "~> 2.5", ">= 2.5.2"
  spec.add_dependency "guard-process", "~> 1.2", ">= 1.2.1"
  spec.add_dependency "guard-coffeescript", "~> 2.0", ">= 2.0.1"
  spec.add_dependency "stylus", "~> 1.0", ">= 1.0.2"
  spec.add_dependency "haml", "~> 4.0", ">= 4.0.7"
  spec.add_dependency "coffee-script", "~> 2.4", ">= 2.4.1"
  spec.add_dependency "haml_coffee_assets", "~> 1.18", ">= 1.18.0"
  spec.add_dependency "jasmine", "~> 2.9", ">= 2.9.0"
  spec.add_dependency "rake", "~> 10.5", ">= 10.5.0"
  spec.add_dependency "uglifier", "~> 4.1", ">= 4.1.5"
  spec.add_dependency "andand", "~> 1.3", ">= 1.3.3"
end
