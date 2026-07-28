# frozen_string_literal: true

# Copyright (c) 2014-2016 The Hybrid Group, 2020-2021 Cody Cutrer

module CCutrer
  class SerialPort < File
    module Termios
      NCCS = 32

      class Termios < FFI::Struct
        layout :c_iflag,
               :uint,
               :c_oflag,
               :uint,
               :c_cflag,
               :uint,
               :c_lflag,
               :uint,
               :c_line,
               :uchar,
               :c_cc,
               [:uchar, NCCS],
               :c_ispeed,
               :uint,
               :c_ospeed,
               :uint
      end

      # c_cc characters
      VTIME = 5
      VMIN = 6

      # c_iflag bits
      IGNPAR = 0o000004

      # c_cflag bits
      CSIZE  = 0o000060
      CSTOPB = 0o000100
      CREAD  = 0o000200
      PARENB = 0o000400
      PARODD = 0o001000
      CLOCAL = 0o004000

      DATA_BITS = {
        5 => 0o000000,
        6 => 0o000020,
        7 => 0o000040,
        8 => 0o000060
      }.freeze

      BAUD_RATES = {
        0 => 0o000000,
        50 => 0o000001,
        75 => 0o000002,
        110 => 0o000003,
        134 => 0o000004,
        150 => 0o000005,
        200 => 0o000006,
        300 => 0o000007,
        600 => 0o000010,
        1200 => 0o000011,
        1800 => 0o000012,
        2400 => 0o000013,
        4800 => 0o000014,
        9600 => 0o000015,
        19_200 => 0o000016,
        38_400 => 0o000017,
        57_600 => 0o010001,
        115_200 => 0o010002,
        230_400 => 0o010003,
        460_800 => 0o010004,
        500_000 => 0o010005,
        576_000 => 0o010006,
        921_600 => 0o010007,
        1_000_000 => 0o010010,
        1_152_000 => 0o010011,
        1_500_000 => 0o010012,
        2_000_000 => 0o010013,
        2_500_000 => 0o010014,
        3_000_000 => 0o010015,
        3_500_000 => 0o010016,
        4_000_000 => 0o010017
      }.freeze

      PARITY = {
        none: 0o000000,
        even: PARENB,
        odd: PARENB | PARODD
      }.freeze

      STOP_BITS = {
        1 => 0o000000,
        2 => CSTOPB
      }.freeze

      TCSANOW = 0
    end
  end
end
