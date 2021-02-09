# Copyright (c) 2014-2016 The Hybrid Group, 2020-2021 Cody Cutrer

module CCutrer::SerialPort::Termios
  attach_function :cfgetispeed, [ Termios ], :uint, blocking: true
  attach_function :cfgetospeed, [ Termios ], :uint, blocking: true
  attach_function :cfsetispeed, [ Termios, :uint ], :int, blocking: true
  attach_function :cfsetospeed, [ Termios, :uint ], :int, blocking: true
  attach_function :tcsetattr, [ :int, :int, Termios ], :int, blocking: true
  attach_function :tcgetattr, [ :int, Termios ], :int, blocking: true
end
