# Copyright (c) 2014-2016 The Hybrid Group, 2020 Cody Cutrer

require 'fcntl'

class CCutrer::SerialPort < File
  def initialize(address, baud: nil, data_bits: nil, parity: nil, stop_bits: nil)
    super(address, IO::RDWR | IO::NOCTTY | IO::NONBLOCK)

    raise IOError, "Not a serial port" unless tty?

    fl = fcntl(Fcntl::F_GETFL, 0)
    fcntl(Fcntl::F_SETFL, ~Fcntl::O_NONBLOCK & fl)

    @termios = Termios::Termios.new
    refresh

    # base config
    @termios[:c_iflag] = Termios::IGNPAR
    @termios[:c_oflag] = 0
    @termios[:c_cflag] =
      Termios::CREAD |
      Termios::CLOCAL
    @termios[:c_lflag] = 0

    @termios[:c_cc][Termios::VTIME] = 0
    @termios[:c_cc][Termios::VMIN] = 0

    configure do
      self.baud = baud if baud
      self.data_bits = data_bits if data_bits
      self.parity = parity if parity
      self.stop_bits = stop_bits if stop_bits
    end
    raise Errno::EINVAL if baud && baud != self.baud
    raise Errno::EINVAL if data_bits && data_bits != self.data_bits
    raise Errno::EINVAL if parity && parity != self.parity
    raise Errno::EINVAL if stop_bits && stop_bits != self.stop_bits
  end

  def configure
    @configuring = true
    yield
    @configuring = false
    apply
    refresh
  ensure
    @configuring = false
  end

  def baud
    Termios::BAUD_RATES.invert[Termios.cfgetispeed(@termios)]
  end

  def baud=(baud)
    raise ArgumentError, "Invalid baud" unless Termios::BAUD_RATES.key?(baud)

    err = Termios.cfsetispeed(@termios, Termios::BAUD_RATES[baud])
    raise SystemCallError, FFI.errno if err == -1
    err = Termios.cfsetospeed(@termios, Termios::BAUD_RATES[baud])
    raise SystemCallError, FFI.errno if err == -1
    apply  
    refresh
    self.baud
  end

  def data_bits
    Termios::DATA_BITS.invert[@termios[:c_cflag] & Termios::CSIZE]
  end

  def data_bits=(data_bits)
    raise ArgumentError, "Invalid data bits" unless Termios::DATA_BITS.key?(data_bits)

    @termios[:c_cflag] &= ~Termios::CSIZE
    @termios[:c_cflag] |= Termios::DATA_BITS[data_bits]
    apply
    refresh
    self.data_bits
  end

  def parity
    Termios::PARITY.invert[@termios[:c_cflag] & Termios::PARITY[:odd]]
  end

  def parity=(parity)
    raise ArgumentError, "Invalid parity" unless Termios::PARITY.key?(parity)

    @termios[:c_cflag] &= ~Termios::PARITY[:odd]
    @termios[:c_cflag] |= Termios::PARITY[parity]
    apply
    refresh
    self.parity
  end

  def stop_bits
    (@termios[:c_cflag] & Termios::CSTOPB) != 0 ? 2 : 1
  end

  def stop_bits=(stop_bits)
    raise ArgumentError, "Invalid stop bits" unless Termios::STOP_BITS.key?(stop_bits)

    @termios[:c_cflag] &= ~Termios::CSTOPB
    @termios[:c_cflag] |= Termios::STOP_BITS[stop_bits]
    apply
    refresh
    self.stop_bits
  end

  def inspect
    "#<#{self.class.name}:#{path} #{baud} #{data_bits}#{parity.to_s[0].upcase}#{stop_bits}>"
  end

  private

  def apply
    return if @configuring
    err = Termios.tcsetattr(fileno, Termios::TCSANOW, @termios)
    raise SystemCallError, FFI.errno if err == -1
    self
  rescue SystemCallError
    begin
      refresh
    rescue SystemCallError
    end
    raise
  end

  def refresh
    return if @configuring
    err = Termios.tcgetattr(fileno, @termios)
    raise SystemCallError, FFI.errno if err == -1
    self
  end
end
