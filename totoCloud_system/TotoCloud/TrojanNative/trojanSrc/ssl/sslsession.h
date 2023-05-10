

#ifndef _SSLSESSION_H_
#define _SSLSESSION_H_

#include <list>
#include <openssl/ssl.h>

class SSLSession {
private:
    static std::list<SSL_SESSION*>sessions;
    static int new_session_cb(SSL*, SSL_SESSION *session);
    static void remove_session_cb(SSL_CTX*, SSL_SESSION *session);
public:
    static SSL_SESSION *get_session();
    static void set_callback(SSL_CTX *context);
};

#endif // _SSLSESSION_H_
