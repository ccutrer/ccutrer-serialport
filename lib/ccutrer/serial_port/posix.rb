# frozen_string_literal: true

# Copyright (c) 2014-2016 The Hybrid Group, 2020-2021 Cody Cutrer

module CCutrer
  class SerialPort < File
    module Termios
      attach_function :cfgetispeed, [Termios], :uint
      attach_function :cfgetospeed, [Termios], :uint
      attach_function :cfsetispeed, [Termios, :uint], :int
      attach_function :cfsetospeed, [Termios, :uint], :int
      attach_function :tcsetattr, [:int, :int, Termios], :int
      attach_function :tcgetattr, [:int, Termios], :int

      begin
        attach_function :cfsetibaud, [Termios, :uint], :int
        attach_function :cfsetobaud, [Termios, :uint], :int
        attach_function :cfgetibaud, [Termios], :uint
        attach_function :cfgetobaud, [Termios], :uint
      rescue FFI::NotFoundError
        # ignore; will fall back to hardcoded constants
      end
    end
  end
end
