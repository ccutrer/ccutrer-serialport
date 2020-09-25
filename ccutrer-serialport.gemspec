$:.push File.expand_path("../lib", __FILE__)
require "ccutrer/serial_port/version"

Gem::Specification.new do |s|
  s.name        = "ccutrer-serialport"
  s.version     = CCutrer::SerialPort::VERSION
  s.summary     = "Linux/OS X RS-232 serial port communication"
  s.description = "Ruby only library that relies on FFI instead of an extension, and inherits from IO"
  s.homepage    = "https://github.com/ccutrer/ccutrer-serialport"
  s.authors     = ["Cody Cutrer"]
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.0'

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'ffi', '~> 1.9', '>= 1.9.3'

  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0.0'
end
