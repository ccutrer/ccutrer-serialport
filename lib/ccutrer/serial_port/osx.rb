# Copyright (c) 2014-2016 The Hybrid Group, 2020 Cody Cutrer

module CCutrer::SerialPort::Posix
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  IGNPAR = 0x00000004
  PARENB = 0x00001000
  PARODD = 0x00002000
  VMIN = 16
  VTIME = 17
  CLOCAL = 0x00008000
  CSTOPB = 0x00000400
  CREAD  = 0x00000800
  CCTS_OFLOW = 0x00010000 # Clearing this disables RTS AND CTS.
  TCSANOW = 0
  NCCS = 20

  DATA_BITS = {
    5 => 0x00000000,
    6 => 0x00000100,
    7 => 0x00000200,
    8 => 0x00000300
  }

  BAUD_RATES = {
    0 => 0,
    50 => 50,
    75 => 75,
    110 => 110,
    134 => 134,
    150 => 150,
    200 => 200,
    300 => 300,
    600 => 600,
    1200 => 1200,
    1800 => 1800,
    2400 => 2400,
    4800 => 4800,
    9600 => 9600,
    19200 => 19200,
    38400 => 38400,
    7200 =>  7200,
    14400 => 14400,
    28800 => 28800,
    57600 => 57600,
    76800 => 76800,
    115200 => 115200,
    230400 => 230400
  }

  PARITY = {
    :none => 0x00000000,
    :even => PARENB,
    :odd => PARENB | PARODD,
  }

  STOPBITS = {
    1 => 0x00000000,
    2 => CSTOPB
  }

  class Termios < FFI::Struct
    layout  :c_iflag, :ulong,
            :c_oflag, :ulong,
            :c_cflag, :ulong,
            :c_lflag, :ulong,
            :c_line, :uchar,
            :cc_c, [ :uchar, NCCS ],
            :c_ispeed, :ulong,
            :c_ospeed, :ulong
  end

  attach_function :tcsetattr, [ :int, :int, Termios ], :int, blocking: true
  attach_function :tcgetattr, [ :int, Termios ], :int, blocking: true
end
