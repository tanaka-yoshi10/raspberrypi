require 'i2c'

class Lcd

  def initialize(path, address = 0x3e)
    @device = I2C.create(path)
    @address = address

    write(0, "\x38\x39\x14\x78\x5e\x6c")
    sleep 0.25
    write(0, "\x0c\x01\x06")
    sleep 0.05
    clear
  end

  def write(addr, data)
    @device.write(@address, addr, data)
  end

  def clear
    write(0, "\x01")
  end

  def move(x,y)
    write(0, 128 + 64 * y + x)
  end

  def disp(text)
    write(0x40, text)
  end
end

display = Lcd.new('/dev/i2c-1')
com1 = open("/dev/ttyACM0","r+");
system(" stty < /dev/ttyACM0 9600")
sleep 2

	com1.write "1"
	stream = ""
	#while c = com1.read(1)
	#  stream += c
	#  break if(c == "\n")
	#end
stream = com1.read(5)
	print stream

	display.clear
	display.move 0,0
	display.disp(stream)
	sleep 1

com1.close
