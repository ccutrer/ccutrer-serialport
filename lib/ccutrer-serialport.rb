# Copyright (c) 2014-2016 The Hybrid Group, 2020 Cody Cutrer

require 'rbconfig'
require 'ffi'

module CCutrer
  class SerialPort < File
    ON_WINDOWS = RbConfig::CONFIG['host_os'] =~ /mswin|windows|mingw/i
    ON_LINUX = RbConfig::CONFIG['host_os'] =~ /linux/i

    if ON_WINDOWS
      raise "rubyserial is not currently supported on windows"
    end

    # order is important here
    require 'ccutrer/serial_port/termios'
    if ON_LINUX
      require 'ccutrer/serial_port/linux'
    else
      require 'ccutrer/serial_port/osx'
    end
    require 'ccutrer/serial_port/posix'
  end
end

require 'ccutrer/serial_port'
require 'ccutrer/serial_port/version'