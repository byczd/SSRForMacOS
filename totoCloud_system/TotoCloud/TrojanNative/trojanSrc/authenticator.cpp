

#include "authenticator.h"
#include <cstdlib>
#include <stdexcept>
using namespace std;

#ifdef ENABLE_MYSQL

Authenticator::Authenticator(const Config &config) {
    mysql_init(&con);
    Log::log_with_date_time("connecting to MySQL server " + config.mysql.server_addr + ':' + to_string(config.mysql.server_port), Log::INFO);
    if (!config.mysql.ca.empty()) {
        if (!config.mysql.key.empty() && !config.mysql.cert.empty()) {
            mysql_ssl_set(&con, config.mysql.key.c_str(), config.mysql.cert.c_str(), config.mysql.ca.c_str(), nullptr, nullptr);
        } else {
            mysql_ssl_set(&con, nullptr, nullptr, config.mysql.ca.c_str(), nullptr, nullptr);
        }
    }
    if (mysql_real_connect(&con, config.mysql.server_addr.c_str(),
                                 config.mysql.username.c_str(),
                                 config.mysql.password.c_str(),
                                 config.mysql.database.c_str(),
                                 config.mysql.server_port, nullptr, 0) == nullptr) {
        throw runtime_error(mysql_error(&con));
    }
    bool reconnect = true;
    mysql_options(&con, MYSQL_OPT_RECONNECT, &reconnect);
    Log::log_with_date_time("connected to MySQL server", Log::INFO);
}

bool Authenticator::auth(const string &password) {
    if (!is_valid_password(password)) {
        return false;
    }
    if (mysql_query(&con, ("SELECT quota, download + upload FROM users WHERE password = '" + password + '\'').c_str())) {
        Log::log_with_date_time(mysql_error(&con), Log::ERROR);
        return false; 
    }
    MYSQL_RES *res = mysql_store_result(&con);
    if (res == nullptr) {
        Log::log_with_date_time(mysql_error(&con), Log::ERROR);
        return false;
    }
    MYSQL_ROW row = mysql_fetch_row(res);
    if (row == nullptr) {
        mysql_free_result(res);
        return false;
    }
    int64_t quota = atoll(row[0]);
    int64_t used = atoll(row[1]);
    mysql_free_result(res);
    if (quota < 0) {
        return true;
    }
    if (used >= quota) {
        Log::log_with_date_time(password + " ran out of quota", Log::WARN);
        return false;
    }
    return true;
}

void Authenticator::record(const string &password, uint64_t download, uint64_t upload) {
    if (!is_valid_password(password)) {
        return;
    }
    if (mysql_query(&con, ("UPDATE users SET download = download + " + to_string(download) + ", upload = upload + " + to_string(upload) + " WHERE password = '" + password + '\'').c_str())) {
        Log::log_with_date_time(mysql_error(&con), Log::ERROR);
    }
}

bool Authenticator::is_valid_password(const string &password) {
    if (password.size() != PASSWORD_LENGTH) {
        return false;
    }
    for (size_t i = 0; i < PASSWORD_LENGTH; ++i) {
        if (!((password[i] >= '0' && password[i] <= '9') || (password[i] >= 'a' && password[i] <= 'f'))) {
            return false;
        }
    }
    return true;
}

Authenticator::~Authenticator() {
    mysql_close(&con);
}

#else // ENABLE_MYSQL

Authenticator::Authenticator(const Config&) {}
bool Authenticator::auth(const string&) { return true; }
void Authenticator::record(const string&, uint64_t, uint64_t) {}
bool Authenticator::is_valid_password(const string&) { return true; }
Authenticator::~Authenticator() {}

#endif // ENABLE_MYSQL