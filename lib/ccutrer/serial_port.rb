# Copyright (c) 2014-2016 The Hybrid Group, 2020 Cody Cutrer

require 'fcntl'

class CCutrer::SerialPort < File
  def initialize(address, baud: 9600, data_bits: 8, parity: :none, stop_bits: 1)
    super(address, IO::RDWR | IO::NOCTTY | IO::NONBLOCK)

    raise IOError, "Not a serial port" unless tty?

    fl = fcntl(Fcntl::F_GETFL, 0)
    fcntl(Fcntl::F_SETFL, ~Fcntl::O_NONBLOCK & fl)

    @config = build_config(baud, data_bits, parity, stop_bits)

    err = Posix.tcsetattr(fileno, Posix::TCSANOW, @config)
    if err == -1
      raise SystemCallError, FFI.errno
    end
  end

  private

  def build_config(baud_rate, data_bits, parity, stop_bits)
    config = Posix::Termios.new

    config[:c_iflag]  = Posix::IGNPAR
    config[:c_ispeed] = Posix::BAUD_RATES[baud_rate]
    config[:c_ospeed] = Posix::BAUD_RATES[baud_rate]
    config[:c_cflag]  = Posix::DATA_BITS[data_bits] |
      Posix::CREAD |
      Posix::CLOCAL |
      Posix::PARITY[parity] |
      Posix::STOPBITS[stop_bits]

    # Masking in baud rate on OS X would corrupt the settings.
    if ON_LINUX
      config[:c_cflag] = config[:c_cflag] | Posix::BAUD_RATES[baud_rate]
    end

    config[:cc_c][Posix::VMIN] = 0

    config
  end
end
