# frozen_string_literal: true

require_relative "lib/ccutrer/serial_port/version"

Gem::Specification.new do |s|
  s.name        = "ccutrer-serialport"
  s.version     = CCutrer::SerialPort::VERSION
  s.summary     = "Linux/OS X RS-232 serial port communication"
  s.description = "Ruby only library that relies on FFI instead of an extension, and inherits from IO"
  s.homepage    = "https://github.com/ccutrer/ccutrer-serialport"
  s.authors     = ["Cody Cutrer"]
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.metadata["rubygems_mfa_required"] = "true"

  s.required_ruby_version = ">= 3.1"

  s.files         = Dir["{lib}/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency "ffi", "~> 1.9", ">= 1.9.3"
end
