

#ifndef _UDPPACKET_H_
#define _UDPPACKET_H_

#include "socks5address.h"

class UDPPacket {
public:
    SOCKS5Address address;
    uint16_t length;
    std::string payload;
    bool parse(const std::string &data, size_t &udp_packet_len);
    static std::string generate(const boost::asio::ip::udp::endpoint &endpoint, const std::string &payload);
    static std::string generate(const std::string &domainname, uint16_t port, const std::string &payload);
};

#endif // _UDPPACKET_H_
