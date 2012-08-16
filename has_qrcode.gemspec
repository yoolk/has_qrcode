# -*- encoding: utf-8 -*-
require File.expand_path('../lib/has_qrcode/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chamnap", "Thaichor"]
  gem.email         = ["chamnapchhorn@gmail.com", "thaichor@gmail.com"]
  gem.description   = %q{Add qrcode to your active_record models}
  gem.summary       = %q{Add qrcode to your active_record models}
  gem.homepage      = "https://github.com/yoolk-os/has_qrcode"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "has_qrcode"
  gem.require_paths = ["lib"]
  gem.version       = HasQrcode::VERSION
  
  gem.add_development_dependency "bundler", ">= 1.1.4"
  gem.add_development_dependency "rspec", "~> 2.8.0"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "jruby-jars", "~> 1.6.7.2"
  gem.add_development_dependency "zxing", "~> 0.3.1"
  
  gem.add_dependency "activerecord", "~> 3.0"
  gem.add_dependency "mini_magick", "~> 3.4"
end
