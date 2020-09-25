# ccutrer-serialport

SerialPort is a simple Ruby gem for interacting with serial ports.

It does not require an extension thanks to using [FFI](https://github.com/ffi/ffi).

SerialPort objects inherit from `File` (and thus `IO`), so are compatible with all
IO methods, in particular `read_partial`, and asynchronous IO.

It was inspired by the [rubyserial](https://github.com/hybridgroup/rubyserial) gem.

## Usage

```ruby
require 'ccutrer-rubyserial'
serialport = CCutrer::SerialPort.new '/dev/ttyACM0' # Defaults to 9600 baud, 8 data bits, and no parity
serialport = CCutrer::SerialPort.new '/dev/ttyACM0', baud: 57600
serialport = CCutrer::SerialPort.new '/dev/ttyACM0', baud: 19200, data_bits: 8, parity: :even

serialport.read(4096)
serialport.gets

require 'io/wait'
serialport.ready?
serialport.wait_readable(1)
```

## Running the tests

The test suite is written using rspec, just use the `rspec` command.

### Test dependencies

To run the tests, you must also have `socat` installed.

## License

MIT. See `LICENSE` for more details.
