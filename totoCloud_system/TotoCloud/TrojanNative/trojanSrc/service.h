
#pragma once

#ifndef _SERVICE_H_
#define _SERVICE_H_

#include <list>
#include <boost/version.hpp>
#include <boost/asio/io_context.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/asio/ip/udp.hpp>
#include <boost/asio/ip/tcp.hpp> //add.by.adong
#include "authenticator.h"
//#include "session/udpforwardsession.h"
#include <string>
using namespace std;

class Service {
private:
    enum {
        MAX_LENGTH = 8192
    };
    const Config &config;
    boost::asio::io_context io_context;
    boost::asio::ip::tcp::acceptor socket_acceptor; //#include <boost/asio/ip/tcp.hpp>
    boost::asio::ssl::context ssl_context;
    Authenticator *auth;
    std::string plain_http_response;
    boost::asio::ip::udp::socket udp_socket;
//    std::list<std::weak_ptr<UDPForwardSession> > udp_sessions;
    uint8_t udp_read_buf[MAX_LENGTH]{};
    boost::asio::ip::udp::endpoint udp_recv_endpoint;
    void async_accept();
    void udp_async_read();
public:
    explicit Service(Config &config,const string &certfile, bool test = false);
    void run();
    void stop();
    boost::asio::io_context &service();
    void reload_cert();
    ~Service();
};

#endif // _SERVICE_H_
