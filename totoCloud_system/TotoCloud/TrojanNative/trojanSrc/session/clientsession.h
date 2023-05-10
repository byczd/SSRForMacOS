

#ifndef _CLIENTSESSION_H_
#define _CLIENTSESSION_H_

#include "session.h"
#include <boost/asio/ssl.hpp>

class ClientSession : public Session {
private:
    enum Status {
        HANDSHAKE,
        REQUEST,
        CONNECT,
        FORWARD,
        UDP_FORWARD,
        INVALID,
        DESTROY
    } status;
    bool is_udp{};
    bool first_packet_recv;
    boost::asio::ip::tcp::socket in_socket;
    boost::asio::ssl::stream<boost::asio::ip::tcp::socket>out_socket;
    void destroy();
    void in_async_read();
    void in_async_write(const std::string &data);
    void in_recv(const std::string &data);
    void in_sent();
    void out_async_read();
    void out_async_write(const std::string &data);
    void out_recv(const std::string &data);
    void out_sent();
    void udp_async_read();
    void udp_async_write(const std::string &data, const boost::asio::ip::udp::endpoint &endpoint);
    void udp_recv(const std::string &data, const boost::asio::ip::udp::endpoint &endpoint);
    void udp_sent();
public:
    ClientSession(const Config &config, boost::asio::io_context &io_context, boost::asio::ssl::context &ssl_context);
    boost::asio::ip::tcp::socket& accept_socket() override;
    void start() override;
};

#endif // _CLIENTSESSION_H_

