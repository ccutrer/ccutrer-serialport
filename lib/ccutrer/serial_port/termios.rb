# Copyright (c) 2014-2016 The Hybrid Group, 2020-2021 Cody Cutrer

module CCutrer
  class SerialPort < File
    module Termios
      extend FFI::Library

      ffi_lib FFI::Library::LIBC
    end
  end
end
