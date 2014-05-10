com1 = open("/dev/ttyACM0","r+");
system(" stty < /dev/ttyACM0 9600")
sleep 2
com1.write "1"

stream = ""
while c = com1.read(1)
  puts c
  stream += c
  break if(c == "\n")
end
print stream
com1.close
