

#ifndef _SOCKS5ADDRESS_H_
#define _SOCKS5ADDRESS_H_

#include <cstdint>
#include <string>
#include <boost/asio/ip/udp.hpp>

class SOCKS5Address {
public:
    enum AddressType {
        IPv4 = 1,
        DOMAINNAME = 3,
        IPv6 = 4
    } address_type;
    std::string address;
    uint16_t port;
    bool parse(const std::string &data, size_t &address_len);
    static std::string generate(const boost::asio::ip::udp::endpoint &endpoint);
};

#endif // _SOCKS5ADDRESS_H_
