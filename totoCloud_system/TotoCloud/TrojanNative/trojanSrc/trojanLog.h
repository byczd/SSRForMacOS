

#ifndef _LOG_H_
#define _LOG_H_

#include <cstdio>
#include <string>
#include <boost/asio/ip/tcp.hpp>

#ifdef ERROR // windows.h
#undef ERROR
#endif // ERROR

class Log {
public:
    enum Level {
        ALL = 0,
        INFO = 1,
        WARN = 2,
        ERROR = 3,
        FATAL = 4,
        OFF = 5
    };
    typedef std::function<void(const std::string &, Level)> LogCallback;
    static Level level;
    static FILE *keylog;
    static void log(const std::string &message, Level level = ALL);
    static void log_with_date_time(const std::string &message, Level level = ALL);
    static void log_with_endpoint(const boost::asio::ip::tcp::endpoint &endpoint, const std::string &message, Level level = ALL);
    static void redirect(const std::string &filename);
    static void redirect_keylog(const std::string &filename);
    static void set_callback(LogCallback cb);
    static void reset();
private:
    static FILE *output_stream;
    static LogCallback log_callback;
};

#endif // _LOG_H_
