#!/usr/bin/ruby
# vim:tabstop=2:expandtab:shiftwidth=2

require File.dirname(__FILE__) + '/echonetlite'

MULTICAST_IF = "192.168.11.22"
#LOCAL_IF = MULTICAST_IF
LOCAL_IF = "0.0.0.0"
#INSTANCELIST = "0401013001"
INSTANCELIST = "0401029001"

udps = UDPSocket.open()

udps.bind(LOCAL_IF, 3610)
#udps.bind(MULTICAST_IF, 3610)

mreq = IPAddr.new("224.0.23.0").hton + IPAddr.new(LOCAL_IF).hton
udps.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, mreq)

multicast_addr = Socket.pack_sockaddr_in(3610, "224.0.23.0")
mif = IPAddr.new(MULTICAST_IF).hton
udps.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_IF, mif)

unicast_addr = Socket.pack_sockaddr_in(3610, "192.168.1.7")

t = Thread.new do
  str = "1081""0000""05FF01""0EF001""73""01""D5" + INSTANCELIST
  puts str

  packet = s_to_h(str)
  udps.send(packet, 0, multicast_addr)
  #udps.send(packet, 0, unicast_addr)

  is_exit = false

  begin
    loop do
      puts 'receive'
      receive_packet, inet_addr =  udps.recvfrom(65535)
      puts "<===== " + inet_addr[3]
      puts receive_packet.unpack("H*")[0]
      map = parse receive_packet

      tid = "%04X" % map[:tid]
      p map
      packet = nil
      case map[:esv]
      when '61'
        deoj = map[:deoj].to_s
        if deoj == "000000"
          str = "1081"+ tid + map[:deoj].to_s + map[:seoj].to_s + "51""01"+map[:epc]+"00"
          is_exit = true
        else
          str = "1081"+ tid + map[:deoj].to_s + map[:seoj].to_s + "71""01"+map[:epc]+"00"
        end
        packet = s_to_h(str)
      when '62'
        case map[:epc]
        when 'd6'
          str = "1081"+ tid + map[:deoj].to_s + map[:seoj].to_s + "72""01""D6" + INSTANCELIST
          packet = s_to_h(str)
        when '80'
        when 'b3'
	  p map[:epcs]
          str = "1081"+ tid + map[:deoj].to_s + map[:seoj].to_s + "72""02""800130B3021234"
          packet = s_to_h(str)
        when '9d'
          str = "1081"+ tid + map[:deoj].to_s + map[:seoj].to_s + "72""01""9d0403808188"
          packet = s_to_h(str)
        when '9e'
          str = "1081"+ tid + map[:deoj].to_s + map[:seoj].to_s + "72""01""9e0403808188"
          packet = s_to_h(str)
        when '9f'
          str = "1081"+ tid + map[:deoj].to_s + map[:seoj].to_s + "72""01""9f0403808188"
          packet = s_to_h(str)
        when '81'
          str = "1081"+ tid + map[:deoj].to_s + map[:seoj].to_s + "72""01""81""01""09"
          # 設置場所コードが0x01の場合、以降に続く16バイトで緯度経度高さを示す
          #str = "1081"+ tid + map[:deoj].to_s + map[:seoj].to_s + "72""01""81""11""01""00001b0000000003""00001b0000000003"  
          packet = s_to_h(str)
        else
          next
        end
      when '63'
        case map[:epc]
        when 'd5'
          str = "1081""0000""05FF01""0EF001""73""01""D5" + INSTANCELIST
          packet = s_to_h(str)

          puts str
          udps.send(packet, 0, multicast_addr) unless packet.nil?
          #		udps.send(packet, 0, unicast_addr) unless packet.nil?
          next
        end
      end

      puts str
      udps.send(packet, 0, inet_addr[3], inet_addr[1]) unless packet.nil?

      if is_exit
        exit
      end

    end
  ensure

    udps.close
  end
end

gets
