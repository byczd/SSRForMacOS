
#pragma once

#ifndef _SESSION_H_
#define _SESSION_H_

#include <ctime>
#include <memory>
#include <boost/asio/io_context.hpp>
#include <boost/asio/ip/udp.hpp>
#include <boost/asio/steady_timer.hpp>
#include <boost/asio/ip/tcp.hpp> //add.by.adong
#include "trojanconf.hpp"

class Session : public std::enable_shared_from_this<Session> {
protected:
    enum {
        MAX_LENGTH = 8192,
        SSL_SHUTDOWN_TIMEOUT = 30
    };
    const Config &config;
    uint8_t in_read_buf[MAX_LENGTH]{};
    uint8_t out_read_buf[MAX_LENGTH]{};
    uint8_t udp_read_buf[MAX_LENGTH]{};
    uint64_t recv_len;
    uint64_t sent_len;
    time_t start_time{};
    std::string out_write_buf;
    std::string udp_data_buf;
    boost::asio::ip::tcp::resolver resolver; //#include <boost/asio/ip/tcp.hpp>
    boost::asio::ip::tcp::endpoint in_endpoint;
    boost::asio::ip::udp::socket udp_socket;
    boost::asio::ip::udp::endpoint udp_recv_endpoint;
    boost::asio::steady_timer ssl_shutdown_timer;
public:
    Session(const Config &config, boost::asio::io_context &io_context);
    virtual boost::asio::ip::tcp::socket& accept_socket() = 0;
    virtual void start() = 0;
    virtual ~Session();
};

#endif // _SESSION_H_
