com1 = open("/dev/rfcomm1","r+");
com1.write "\x10\x81\x00\x00\x0e\xf0\x00\x00\x11\x00\x62\x01\xe0\x00"

stream = ""
while c = com1.read(1)
  stream += c
  break if(c == "\n")
end
print stream
com1.close
