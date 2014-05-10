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
