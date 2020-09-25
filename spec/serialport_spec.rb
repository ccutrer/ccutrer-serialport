require 'ccutrer-serialport'

describe CCutrer::SerialPort do
  before do
    @ports = []
    File.delete('socat.log') if File.file?('socat.log')

    raise 'socat not found' unless (`socat -h` && $? == 0)

    Thread.new do
      system('socat -lf socat.log -d -d pty,raw,echo=0 pty,raw,echo=0')
    end

    @ptys = nil

    loop do
      if File.file? 'socat.log'
        @file = File.open('socat.log', "r")
        @fileread = @file.read

        unless @fileread.count("\n") < 3
          @ptys = @fileread.scan(/PTY is (.*)/)
          break
        end
      end
    end

    @ports = [@ptys[1][0], @ptys[0][0]]

    @sp2 = CCutrer::SerialPort.new(@ports[0])
    @sp = CCutrer::SerialPort.new(@ports[1])
  end

  after do
   @sp2.close
   @sp.close
  end

  it "should read and write" do
    @sp2.write('hello')
    # small delay so it can write to the other port.
    sleep 0.1
    check = @sp.read(5)
    expect(check).to eql('hello')
  end

  it "should convert ints to strings" do
    expect(@sp2.write(123)).to eql(3)
    sleep 0.1
    expect(@sp.read(3)).to eql('123')
  end

  it "write should return bytes written" do
    expect(@sp2.write('hello')).to eql(5)
  end

  it "reading nothing should be blank" do
    expect(@sp.read(5)).to be_nil
  end

  it "should give me nil on getbyte" do
    expect(@sp.getbyte).to be_nil
  end

  it 'should give me a zero byte from getbyte' do
    @sp2.write("\x00")
    sleep 0.1
    expect(@sp.getbyte).to eql(0)
  end

  it "should give me bytes" do
    @sp2.write('hello')
    # small delay so it can write to the other port.
    sleep 0.1
    check = @sp.getbyte
    expect([check].pack('C')).to eql('h')
  end

  describe "giving me lines" do
    it "should give me a line" do
      @sp.write("no yes \n hello")
      sleep 0.1
      expect(@sp2.gets).to eql("no yes \n")
    end

    it "should give me a line with block" do
      @sp.write("no yes \n hello")
      sleep 0.1
      result = ""
      @sp2.each_line do |line|
        result = line
        break if !result.empty?
      end
      expect(result).to eql("no yes \n")
    end

    it "should accept a sep param" do
      @sp.write('no yes END bleh')
      sleep 0.1
      expect(@sp2.gets('END')).to eql("no yes END")
    end

    it "should accept a limit param" do
      @sp.write("no yes \n hello")
      sleep 0.1
      expect(@sp2.gets(4)).to eql("no y")
    end

    it "should accept limit and sep params" do
      @sp.write("no yes END hello")
      sleep 0.1
      expect(@sp2.gets('END', 20)).to eql("no yes END")
      @sp2.read(1000)
      @sp.write("no yes END hello")
      sleep 0.1
      expect(@sp2.gets('END', 4)).to eql('no y')
    end

    it "should read a paragraph at a time" do
      @sp.write("Something \n Something else \n\n and other stuff")
      sleep 0.1
      expect(@sp2.gets('')).to eql("Something \n Something else \n\n")
    end
  end

  describe 'config' do
    it 'should accept EVEN parity' do
      @sp2.close
      @sp.close
      @sp2 = CCutrer::SerialPort.new(@ports[0], baud: 19200, data_bits: 8, parity: :even)
      @sp = CCutrer::SerialPort.new(@ports[1], baud: 19200, data_bits: 8, parity: :even)
      @sp.write("Hello!\n")
      sleep 0.1
      expect(@sp2.gets).to eql("Hello!\n")
    end

    it 'should accept ODD parity' do
      @sp2.close
      @sp.close
      @sp2 = CCutrer::SerialPort.new(@ports[0], baud: 19200, data_bits: 8, parity: :odd)
      @sp = CCutrer::SerialPort.new(@ports[1], baud: 19200, data_bits: 8, parity: :odd)
      @sp.write("Hello!\n")
      sleep 0.1
      expect(@sp2.gets).to eql("Hello!\n")
    end

    it 'should accept 1 stop bit' do
      @sp2.close
      @sp.close
      @sp2 = CCutrer::SerialPort.new(@ports[0], baud: 19200, data_bits: 8, parity: :none, stop_bits: 1)
      @sp = CCutrer::SerialPort.new(@ports[1], baud: 19200, data_bits: 8, parity: :none, stop_bits: 1)
      @sp.write("Hello!\n")
      sleep 0.1
      expect(@sp2.gets).to eql("Hello!\n")
    end

    it 'should accept 2 stop bits' do
      @sp2.close
      @sp.close
      @sp2 = CCutrer::SerialPort.new(@ports[0], baud: 19200, data_bits: 8, parity: :none, stop_bits: 2)
      @sp = CCutrer::SerialPort.new(@ports[1], baud: 19200, data_bits: 8, parity: :none, stop_bits: 2)
      @sp.write("Hello!\n")
      sleep 0.1
      expect(@sp2.gets).to eql("Hello!\n")
    end

    it 'should set baud rate, check #46 fixed' do
      @sp.close
      rate = 600
      @sp = CCutrer::SerialPort.new(@ports[1], baud: rate)
      fd = @sp.fileno
      termios = CCutrer::SerialPort::Posix::Termios.new
      CCutrer::SerialPort::Posix.tcgetattr(fd, termios)
      expect(termios[:c_ispeed]).to eql(CCutrer::SerialPort::Posix::BAUD_RATES[rate])
    end
  end
end
