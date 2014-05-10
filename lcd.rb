#!/usr/bin/env ruby

require 'rubygems'
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

sensor = Lcd.new('/dev/i2c-1')
sensor.move 0,0
sensor.disp(`hostname`.chop)
sensor.move 0,1
sensor.disp(`hostname -I`.chop)

GPIO = 4

exp = open("/sys/class/gpio/export", "w")
exp.write(GPIO)
exp.close
 
dir = open("/sys/class/gpio/gpio#{GPIO}/direction", "w")
dir.write("out")
dir.close
 
out = 1
20.times do
  val = open("/sys/class/gpio/gpio#{GPIO}/value", "w")
  val.write(out)
  val.close
  out = out == 1 ? 0 : 1
  sleep 0.5
end
 
uexp = open("/sys/class/gpio/unexport", "w")
uexp.write(GPIO)
uexp.close
