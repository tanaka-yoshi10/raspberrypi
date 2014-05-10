SWITCH_GPIO = 4
LED_GPIO = 17

#exp = open("/sys/class/gpio/export", "w")
#exp.write(SWITCH_GPIO)
#exp.close
 
#dir = open("/sys/class/gpio/gpio#{SWITCH_GPIO}/direction", "w")
#dir.write("in")
#dir.close

#val = open("/sys/class/gpio/gpio#{SWITCH_GPIO}/value", "w")
#val.write("1")
#val.close

#exp = open("/sys/class/gpio/export", "w")
#exp.write(LED_GPIO)
#exp.close
 
#dir = open("/sys/class/gpio/gpio#{LED_GPIO}/direction", "w")
#dir.write("in")
#dir.close
 
#val = open("/sys/class/gpio/gpio#{SWITCH_GPIO}/value", "r")
#20.times do
loop do
#  puts val.read(1)
  puts switch = `cat /sys/class/gpio/gpio#{SWITCH_GPIO}/value`
  if switch.strip == "0"
    `echo "0" > /sys/class/gpio/gpio#{LED_GPIO}/value`
  else
    `echo "1" > /sys/class/gpio/gpio#{LED_GPIO}/value`
  end
  sleep 1
end
#val.close
 
#uexp = open("/sys/class/gpio/unexport", "w")
#uexp.write(SWITCH_GPIO)
#uexp.close

#uexp = open("/sys/class/gpio/unexport", "w")
#uexp.write(LED_GPIO)
#uexp.close
