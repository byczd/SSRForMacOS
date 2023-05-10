

#ifndef _AUTHENTICATOR_H_
#define _AUTHENTICATOR_H_

#ifdef ENABLE_MYSQL
#include <mysql.h>
#endif // ENABLE_MYSQL
#include "trojanconf.hpp"

class Authenticator {
private:
#ifdef ENABLE_MYSQL
    MYSQL con{};
#endif // ENABLE_MYSQL
    enum {
        PASSWORD_LENGTH=56
    };
    static bool is_valid_password(const std::string &password);
public:
    explicit Authenticator(const Config &config);
    bool auth(const std::string &password);
    void record(const std::string &password, uint64_t download, uint64_t upload);
    ~Authenticator();
};

#endif // _AUTHENTICATOR_H_
