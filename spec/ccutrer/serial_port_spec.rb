# frozen_string_literal: true

describe CCutrer::SerialPort do
  let(:socat_pid) { spawn("socat -lf socat.log -d -d pty,raw,echo=0 pty,raw,echo=0") }
  let(:ports) do
    File.delete("socat.log") if File.file?("socat.log")

    `socat -h`
    raise "socat not found" unless $?.success?

    socat_pid

    ptys = nil

    loop do
      next unless File.file?("socat.log")

      socat_log = File.read("socat.log")

      unless socat_log.count("\n") < 3
        ptys = socat_log.scan(/PTY is (.*)/)
        break
      end
    end

    [ptys[1][0], ptys[0][0]]
  end
  let(:sp) { CCutrer::SerialPort.new(ports[1]) }
  let(:sp2) { CCutrer::SerialPort.new(ports[0]) }

  after do
    begin
      sp.close
    rescue Errno::ENOENT
      # ignore
    end
    begin
      sp2.close
    rescue Errno::ENOENT
      # ignore
    end
    begin
      Process.kill("TERM", socat_pid)
      Process.wait(socat_pid)
    rescue Errno::ESRCH, Errno::ECHILD
      # socat already exited
    end
  end

  it "should read and write" do
    sp2.write("hello")
    # small delay so it can write to the other port.
    sleep 0.1
    expect(sp.read(5)).to eql("hello")
  end

  it "should convert ints to strings" do
    expect(sp2.write(123)).to be(3)
    sleep 0.1
    expect(sp.read(3)).to eql("123")
  end

  it "write should return bytes written" do
    expect(sp2.write("hello")).to be(5)
  end

  it "reading nothing should be blank" do
    expect(sp.read(5)).to be_nil
  end

  it "should return available data without waiting for the requested length" do
    sp2.write("hi")
    sleep 0.1
    expect(sp.read(5)).to eql("hi")
  end

  it "should give me nil on getbyte" do
    expect(sp.getbyte).to be_nil
  end

  it "should give me a zero byte from getbyte" do
    sp2.write("\x00")
    sleep 0.1
    expect(sp.getbyte).to be(0)
  end

  it "should give me bytes" do
    sp2.write("hello")
    # small delay so it can write to the other port.
    sleep 0.1
    expect(sp.getbyte.chr).to eql("h")
  end

  describe "giving me lines" do
    it "should give me a line" do
      sp.write("no yes \n hello")
      sleep 0.1
      expect(sp2.gets).to eql("no yes \n")
    end

    it "should give me a line with block" do
      sp.write("no yes \n hello")
      sleep 0.1
      result = ""
      sp2.each_line do |line|
        result = line
        break unless result.empty?
      end
      expect(result).to eql("no yes \n")
    end

    it "should accept a sep param" do
      sp.write("no yes END bleh")
      sleep 0.1
      expect(sp2.gets("END")).to eql("no yes END")
    end

    it "should accept a limit param" do
      sp.write("no yes \n hello")
      sleep 0.1
      expect(sp2.gets(4)).to eql("no y")
    end

    it "should accept limit and sep params" do
      sp.write("no yes END hello")
      sleep 0.1
      expect(sp2.gets("END", 20)).to eql("no yes END")
      sp2.read(1000)
      sp.write("no yes END hello")
      sleep 0.1
      expect(sp2.gets("END", 4)).to eql("no y")
    end

    it "should read a paragraph at a time" do
      sp.write("Something \n Something else \n\n and other stuff")
      sleep 0.1
      expect(sp2.gets("")).to eql("Something \n Something else \n\n")
    end
  end

  describe "config" do
    it "should accept EVEN parity", skip: "Not possible with socat" do
      sp2 = CCutrer::SerialPort.new(ports[0], baud: 19_200, data_bits: 8, parity: :even)
      sp = CCutrer::SerialPort.new(ports[1], baud: 19_200, data_bits: 8, parity: :even)
      sp.write("Hello!\n")
      sleep 0.1
      expect(sp2.gets).to eql("Hello!\n")
    end

    it "should accept ODD parity", skip: "Not possible with socat" do
      sp2 = CCutrer::SerialPort.new(ports[0], baud: 19_200, data_bits: 8, parity: :odd)
      sp = CCutrer::SerialPort.new(ports[1], baud: 19_200, data_bits: 8, parity: :odd)
      sp.write("Hello!\n")
      sleep 0.1
      expect(sp2.gets).to eql("Hello!\n")
    end

    it "should accept 1 stop bit" do
      sp2 = CCutrer::SerialPort.new(ports[0], baud: 19_200, data_bits: 8, parity: :none, stop_bits: 1)
      sp = CCutrer::SerialPort.new(ports[1], baud: 19_200, data_bits: 8, parity: :none, stop_bits: 1)
      sp.write("Hello!\n")
      sleep 0.1
      expect(sp2.gets).to eql("Hello!\n")
    end

    it "should accept 2 stop bits" do
      sp2 = CCutrer::SerialPort.new(ports[0], baud: 19_200, data_bits: 8, parity: :none, stop_bits: 2)
      sp = CCutrer::SerialPort.new(ports[1], baud: 19_200, data_bits: 8, parity: :none, stop_bits: 2)
      sp.write("Hello!\n")
      sleep 0.1
      expect(sp2.gets).to eql("Hello!\n")
    end

    it "should set baud rate, check #46 fixed" do
      rate = 600
      sp = CCutrer::SerialPort.new(ports[1], baud: rate)
      fd = sp.fileno
      termios = CCutrer::SerialPort::Termios::Termios.new
      CCutrer::SerialPort::Termios.tcgetattr(fd, termios)
      expect(termios[:c_ispeed]).to eql(CCutrer::SerialPort::Termios::BAUD_RATES[rate])
    end
  end
end
