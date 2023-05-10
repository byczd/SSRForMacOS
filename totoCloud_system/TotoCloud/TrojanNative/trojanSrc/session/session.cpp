

#include "session.h"

Session::Session(const Config &config, boost::asio::io_context &io_context) : config(config),
                                                                              recv_len(0),
                                                                              sent_len(0),
                                                                              resolver(io_context),
                                                                              udp_socket(io_context),
                                                                              ssl_shutdown_timer(io_context) {}

Session::~Session() = default;
