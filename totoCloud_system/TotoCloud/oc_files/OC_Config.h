//
//  OC_Config.h
//  TotoCloud
//
//  Created by 黄龙 on 2023/4/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const USERDEFAULTS_GFW_LIST_URL = @"GFWListURL";
static NSString * const USERDEFAULTS_ACL_WHITE_LIST_URL = @"ACLWhiteListURL";
static NSString * const USERDEFAULTS_ACL_AUTO_LIST_URL = @"ACLAutoListURL";
static NSString * const USERDEFAULTS_ACL_PROXY_BACK_CHN_URL = @"ACLProxyBackCHNURL";
static NSString * const USERDEFAULTS_RUNNING_MODE = @"RunningMode";
static NSString * const USERDEFAULTS_ACL_FILE_NAME = @"ACLFileName";
static NSString * const USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT = @"LocalSocks5.ListenPort";
static NSString * const USERDEFAULTS_LOCAL_SOCKS5_LISTEN_ADDRESS = @"LocalSocks5.ListenAddress";
static NSString * const USERDEFAULTS_LOCAL_HTTP_LISTEN_ADDRESS = @"LocalHTTP.ListenAddress";
static NSString * const USERDEFAULTS_LOCAL_HTTP_LISTEN_PORT = @"LocalHTTP.ListenPort";
static NSString * const USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT_OLD = @"LocalSocks5.ListenPort.Old";
static NSString * const USERDEFAULTS_PAC_SERVER_LISTEN_ADDRESS = @"PacServer.ListenAddress";
static NSString * const USERDEFAULTS_PAC_SERVER_LISTEN_PORT = @"PacServer.ListenPort";
static NSString * const USERDEFAULTS_LOCAL_HTTP_ON = @"LocalHTTPOn";
static NSString * const USERDEFAULTS_LOCAL_HTTP_FOLLOW_GLOBAL = @"LocalHTTP.FollowGlobal";
static NSString * const USERDEFAULTS_AUTO_CONFIGURE_NETWORK_SERVICES = @"AutoConfigureNetworkServices";
static NSString * const USERDEFAULTS_PROXY4_NETWORK_SERVICES = @"Proxy4NetworkServices";
static NSString * const USERDEFAULTS_AUTO_CHECK_UPDATE = @"USERDEFAULTS_AUTO_CHECK_UPDATE";
static NSString * const USERDEFAULTS_ENABLE_SHOW_SPEED = @"USERDEFAULTS_ENABLE_SHOW_SPEED";
static NSString * const USERDEFAULTS_FIXED_NETWORK_SPEED_VIEW_WIDTH = @"USERDEFAULTS_FIXED_NETWORK_SPEED_VIEW_WIDTH";
static NSString * const USERDEFAULTS_SUBSCRIBES = @"USERDEFAULTS_SUBSCRIBES";
static NSString * const USERDEFAULTS_SPEED_TEST_AFTER_SUBSCRIPTION = @"USERDEFAULTS_SPEED_TEST_AFTER_SUBSCRIPTION";
static NSString * const USERDEFAULTS_FASTEST_NODE = @"USERDEFAULTS_FASTEST_NODE";

@interface OC_Config : NSObject

@end

NS_ASSUME_NONNULL_END
