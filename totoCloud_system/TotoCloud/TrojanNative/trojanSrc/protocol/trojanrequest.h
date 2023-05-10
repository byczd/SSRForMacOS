

#ifndef _TROJANREQUEST_H_
#define _TROJANREQUEST_H_

#include "socks5address.h"

class TrojanRequest {
public:
    std::string password;
    enum Command {
        CONNECT = 1,
        UDP_ASSOCIATE = 3
    } command;
    SOCKS5Address address;
    std::string payload;
    int parse(const std::string &data);
    static std::string generate(const std::string &password, const std::string &domainname, uint16_t port, bool tcp);
};

#endif // _TROJANREQUEST_H_
