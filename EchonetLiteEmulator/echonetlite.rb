#! ruby -Ks
# vim:tabstop=2:expandtab:shiftwidth=2

require "socket"
require "ipaddr"

ESV_MAP = {
=begin
  0x60 => "プロパティ値書き込み要求(応答不要)",
  0x61 => "プロパティ値書き込み要求(応答要)",
  0x62 => "プロパティ値読み出し要求",
  0x63 => "プロパティ値通知要求",
  0x6E => "プロパティ値書き込み,読み出し要求",

  0x71 => "プロパティ値書き込み応答",
  0x72 => "プロパティ値読み出し応答",
  0x73 => "プロパティ値通知",
  0x74 => "プロパティ値通知(応答要)",
  0x7A => "プロパティ値通知応答",
  0x7E => "プロパティ値書き込み・読み出し応答",

  0x50 => "プロパティ値書き込み要求不可応答",
  0x51 => "プロパティ値書き込み要求不可応答",
  0x52 => "プロパティ値読み出し不可応答",
  0x53 => "プロパティ値通知不可応答",
  0x5E => "プロパティ値書き込み,読み出し不可応答",
=end
}

def parse_property(size, data)
  map = []
  i = 0
  size.times do
    epc = data[i]
    i+=1
    pdc = data[i].to_i
    i+=1
    if pdc > 0
      edt = data[i,pdc]
      i+=pdc
    else
      edt = ""
    end
p epc
    epc = "%02x" % epc.to_i
    puts "EPC :  0x#{epc}"
    puts "PDC :  #{pdc}"
    pdt = h_to_s(edt)
    puts "PDT :  " + pdt
    map << {:epc => epc, :pdt => pdt}
    if epc == 0xd5 && edt != ""
      puts edt[0]
      i = 1
      eojs = []
      while i < edt.size
        eojs << h_to_s(edt[i,3])
        i += 3
      end
      puts eojs.join(",")
    end
  end
  return map
end

def convertEsv(esv)
  if ESV_MAP.include?(esv)
    ESV_MAP[esv]
  else
    ""
  end
end

def parse(packet)
  map = {}
  header = packet.unpack("a2na3a3cca*")
  puts "SEOJ : " + h_to_s(header[2])
  puts "DEOJ : " + h_to_s(header[3])
  puts "ESV  : 0x%02x " % header[4] + convertEsv(header[4])
  puts "OPC  : #{header[5]}"
  map[:epc] = h_to_s(header[6])[0,2]
  map[:esv] = "%02x" % header[4] 
  epc_map = parse_property(header[5], header[6])

  map[:tid] = header[1]
  map[:seoj] = h_to_s(header[2])
  map[:deoj] = h_to_s(header[3])
  map[:epcs] = epc_map
  return map
end

def h_to_s hexcode
  hexcode.unpack("H*")[0]
end

def s_to_h str
  packet = [ str ].pack("H*")
end

def propertymap(data)
  puts data
  hex = s_to_h(data)
  size = hex[0].to_i
  puts "size = #{hex[0].to_i}"
  if size < 16
    #hex.each_byte
  else
    map = []
    16.times do |i|
      #puts "%02X" % hex[i]
      map << "0x%02X" % (0x80 + (i)) if hex[i+1] & 0x01 != 0
      map << "0x%02X" % (0x90 + (i)) if hex[i+1] & 0x02 != 0
      map << "0x%02X" % (0xA0 + (i)) if hex[i+1] & 0x04 != 0
      map << "0x%02X" % (0xB0 + (i)) if hex[i+1] & 0x08 != 0
      map << "0x%02X" % (0xC0 + (i)) if hex[i+1] & 0x10 != 0
      map << "0x%02X" % (0xD0 + (i)) if hex[i+1] & 0x20 != 0
      map << "0x%02X" % (0xE0 + (i)) if hex[i+1] & 0x40 != 0
      map << "0x%02X" % (0xF0 + (i)) if hex[i+1] & 0x80 != 0
    end

    p map.sort
    p map.size
  end
end

if __FILE__ == $0
  require 'test/unit'
  require "pp"
  #data = "160B010109000000010101030303030303"
  data = "3a1f1f1b0e1e0e0b1b0b191f1d19191919"
  #propertymap(data)

  class TC_Foo < Test::Unit::TestCase
    def test_parse
      ret = parse(s_to_h("1081327c05ff0100000062018100"))
      pp ret
      assert_equal("05ff01", ret[:seoj])
      assert_equal("000000", ret[:deoj])
      assert_equal("81", ret[:epcs][0][:epc])
      assert_equal("81", ret[:epc])
    end
  end
  puts 'notify'
  #data = "0706808188daf0ff"

  # 20130207 JX
  #[02/07 16:32:27][INFO   ]:RECV udp packet from 192.168.0.10:10810001027c0105ff0172019d1104808188ca000000000000000000000000
  data = "11808188ca000000000000000000000000"
  propertymap(data)

  # 20130809 JX
  #[08/07 11:55:56][INFO   ]:RECV udp packet from 192.168.11.3:10810001027c0105ff0172019d1104808188ca000000000000000000000000
  data = "11808188ca000000000000000000000000"
  propertymap(data)

  puts 'set'
  #data = "1128e1616162616161232321234141010101"

  # 20130207 JX
  #[02/07 16:32:27][INFO   ]:RECV udp packet from 192.168.0.10:10810002027c0105ff0172019e110481c6c9d6000000000000000000000000
  data = "1181c6c9d6000000000000000000000000"
  propertymap(data)

  # 20130807 JX
  # [08/07 11:55:56][INFO   ]:RECV udp packet from 192.168.11.3:10810002027c0105ff0172019e110381c6c900000000000000000000000000
  data = "1181c6c900000000000000000000000000"
  propertymap(data)

  puts 'get'
  #data = "14808182888a9d9e9fd3dae4e600020202"
  data = "2121315131703001121301130101030302"
  propertymap(data)
  data = "1f21315131501001121301130101030302"
  propertymap(data)
end
