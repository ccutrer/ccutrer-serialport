# frozen_string_literal: true

# Copyright (c) 2014-2016 The Hybrid Group, 2020-2021 Cody Cutrer

module CCutrer
  class SerialPort < File
    module Termios
      NCCS = 20

      class Termios < FFI::Struct
        layout :c_iflag,
               :ulong,
               :c_oflag,
               :ulong,
               :c_cflag,
               :ulong,
               :c_lflag,
               :ulong,
               :c_line,
               :uchar,
               :c_cc,
               [:uchar, NCCS],
               :c_ispeed,
               :ulong,
               :c_ospeed,
               :ulong
      end

      # c_cc characters
      VMIN = 16
      VTIME = 17

      # c_iflag bits
      IGNPAR = 0x00000004

      # c_cflag bits
      CSIZE  = 0x00000700
      CSTOPB = 0x00000400
      CREAD  = 0x00000800
      PARENB = 0x00001000
      PARODD = 0x00002000
      CLOCAL = 0x00008000

      DATA_BITS = {
        5 => 0x00000000,
        6 => 0x00000100,
        7 => 0x00000200,
        8 => 0x00000300
      }.freeze

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
        19_200 => 19_200,
        38_400 => 38_400,
        7200 => 7200,
        14_400 => 14_400,
        28_800 => 28_800,
        57_600 => 57_600,
        76_800 => 76_800,
        115_200 => 115_200,
        230_400 => 230_400
      }.freeze

      PARITY = {
        none: 0x00000000,
        even: PARENB,
        odd: PARENB | PARODD
      }.freeze

      STOP_BITS = {
        1 => 0x00000000,
        2 => CSTOPB
      }.freeze

      TCSANOW = 0
    end
  end
end
