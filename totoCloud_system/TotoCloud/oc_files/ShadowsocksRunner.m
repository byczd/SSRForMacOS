//
// Created by clowwindy on 14-2-27.
// Copyright (c) 2014 clowwindy. All rights reserved.
//

#import "ShadowsocksRunner.h"
//#import "SWBAppDelegate.h"
#import "SSRProfile.h"
#import "Configuration.h"
//#import "SSRProfileManager.h"

//ssr-shadowsocksProxy

#include <ssrNative/ssrNative.h>
//每次CleanMyMac清理一下，就报该头文件找不到，见鬼了？！
//原来是ssrNative导入后，没有在Link Binary中将ssrNative.framework加入

//-------trojan
#import "TrojanManager.h"

static uint16_t retrieve_socket_port(int socket) {
    char tmp[256] = { 0 }; // buffer size must big enough
    socklen_t len = sizeof(tmp);
    if (getsockname(socket, (struct sockaddr*)tmp, &len) != 0) {
        return 0;
    }
    else {
        return ntohs(((struct sockaddr_in*)tmp)->sin_port);
    }
}

//将SSRProfile节点，转成 server_config 结构数据
struct server_config * build_config_object(SSRProfile *profile, unsigned short port) {
    const char *protocol = profile.protocol.UTF8String;
    if (protocol && strcmp(protocol, "verify_sha1") == 0) {
        // LOGI("The verify_sha1 protocol is deprecate! Fallback to origin protocol.");
        protocol = NULL;
        return NULL;
    }
//
    struct server_config *config = config_create(); //默认值初始化创建
    config->listen_port = port;
    string_safe_assign(&config->method, profile.method.UTF8String);
    string_safe_assign(&config->remote_host, profile.server.UTF8String);
    config->remote_port = (unsigned short) profile.serverPort;
    string_safe_assign(&config->password, profile.password.UTF8String);
    string_safe_assign(&config->protocol, protocol);
    string_safe_assign(&config->protocol_param, profile.protocolParam.UTF8String);
    string_safe_assign(&config->obfs, profile.obfs.UTF8String);
    string_safe_assign(&config->obfs_param, profile.obfsParam.UTF8String);
    string_safe_assign(&config->remarks, profile.remarks.UTF8String);
    config->over_tls_enable = (profile.ot_enable != NO);
    string_safe_assign(&config->over_tls_server_domain, profile.ot_domain.UTF8String);
    string_safe_assign(&config->over_tls_path, profile.ot_path.UTF8String);

    return config;

}
//
struct ssr_client_state *g_state = NULL;
//
void feedback_state(struct ssr_client_state *state, void *p) {
//通知shadowsocksPort，trojan默认是10800，而ssr则是启动打开的端口
    g_state = state;
//    SWBAppDelegate *appDelegate = (__bridge SWBAppDelegate *)p; //改用通知
    int realPort = retrieve_socket_port(ssr_get_listen_socket_fd(state));
//    appDelegate.workingListenPort = realPort;
//    [appDelegate modifySystemProxySettings:YES port:realPort];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_REFRESH_SHADOWSOCKSPORT" object:nil userInfo:@{@"port":[NSString stringWithFormat:@"%d",realPort]}];
}
//
void dump_info_callback(int dump_level, const char *info, void *p) {
    (void)p;
    printf("%s", info);
}
//
void ssr_main_loop(unsigned short listenPort, const char *appPath, void*p) {
    struct server_config *config = NULL;
    do {
        set_app_name(appPath);
        set_dump_info_callback(&dump_info_callback, NULL);
        SSRProfile *profile = [ShadowsocksRunner getCurrentNodeProfile];//[ShadowsocksRunner battleFrontGetProfile];
        config = build_config_object(profile, listenPort);
        if (config == NULL) {
            NSLog(@"err.ssr.config");
            break;
        }

        config_ssrot_revision(config);

        if (config->method == NULL || config->password==NULL || config->remote_host==NULL) {
            break;
        }

        ssr_run_loop_begin(config, &feedback_state, p);
        g_state = NULL;
    } while(0);

    config_release(config);
}
//
void ssr_stop(void) {
    ssr_run_loop_shutdown(g_state);
}
//
@implementation ShadowsocksRunner {
}
//
//+ (BOOL)settingsAreNotComplete {
//    if (([[NSUserDefaults standardUserDefaults] stringForKey:kShadowsocksIPKey] == nil ||
//         [[NSUserDefaults standardUserDefaults] stringForKey:kShadowsocksPortKey] == nil ||
//         [[NSUserDefaults standardUserDefaults] stringForKey:kShadowsocksPasswordKey] == nil))
//    {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
+(void)stopSSRProxy{
    ssr_stop();
}

+ (BOOL) runProxy:(id)p {
    unsigned short port = 0;//(unsigned short) [appDelegate correctListenPort];
    
    BOOL result = NO;
 
    NSString *path = [NSBundle mainBundle].executablePath;
    ssr_main_loop(port, path.UTF8String, (__bridge void *)p); //(__bridge void *)(appDelegate)
//    usleep(200000);
    //一般情况下,延迟时间数量级是秒的时候,尽可能使用sleep()函数。如果延迟时间为几十毫秒,或者更小,尽可能使用usleep()函数
    result = YES;

    return result;
}
//
//+ (void) reloadConfig {
//    //    if (![ShadowsocksRunner settingsAreNotComplete]) {
//    //        ssr_stop();
//    //        dispatch_async(dispatch_get_main_queue(), ^{
//    //            SWBAppDelegate *appDelegate;
//    //            appDelegate = (SWBAppDelegate *) [NSApplication sharedApplication].delegate;
//    //            appDelegate.workingListenPort = 0;
//    //        });
//    //    }
//}
//
//+ (SSRProfile *) profileFromServerConfig:(struct server_config *)config {
//    SSRProfile *profile = [[SSRProfile alloc] init];
//    
//    profile.method = [NSString stringWithUTF8String:config->method];
//    profile.password = [NSString stringWithUTF8String:config->password];
//    profile.server = [NSString stringWithUTF8String:config->remote_host];
//    profile.serverPort = config->remote_port;
//    
//    profile.protocol = [NSString stringWithUTF8String:config->protocol];
//    profile.protocolParam = [NSString stringWithUTF8String:config->protocol_param?:""];
//    profile.obfs = [NSString stringWithUTF8String:config->obfs];
//    profile.obfsParam = [NSString stringWithUTF8String:config->obfs_param?:""];
//    profile.ot_enable = (config->over_tls_enable != false);
//    profile.ot_domain = [NSString stringWithUTF8String:config->over_tls_server_domain?:""];
//    profile.ot_path = [NSString stringWithUTF8String:config->over_tls_path?:""];
//    
//    profile.remarks = [NSString stringWithUTF8String:config->remarks?:""];
//
//    return profile;
//}
//
//+ (BOOL)openSSURL:(NSURL *)url {
//    if (!url.host) {
//        return NO;
//    }
//    
//    struct server_config *config = ssr_qr_code_decode([url absoluteString].UTF8String);
//    if (config == NULL) {
//        return NO;
//    }
//    
//    SSRProfile *profile = [[self class] profileFromServerConfig:config];
//
//    config_release(config);
//
//    Configuration *configuration = [SSRProfileManager configuration];
//    [configuration.profiles addObject:profile];
//    [SSRProfileManager saveConfiguration:configuration];
//    
//    [ShadowsocksRunner reloadConfig];
//
//    SWBAppDelegate *appDelegate = (SWBAppDelegate *) [NSApplication sharedApplication].delegate;
//    NSAssert([appDelegate isKindOfClass:[SWBAppDelegate class]], @"SWBAppDelegate");
//    [appDelegate updateMenu];
//    
//    return YES;
//}
//
//+(NSURL *)generateSSURL {
//    char *qrCode = NULL;
//
//    SSRProfile *profile = [ShadowsocksRunner battleFrontGetProfile];
//    struct server_config *config = build_config_object(profile, 0);
//    qrCode = ssr_qr_code_encode(config, &malloc);
//    config_release(config);
//
//    NSString *r = [NSString stringWithUTF8String:qrCode];
//    free(qrCode);
//    
//    return [NSURL URLWithString:r];
//}
//
+ (void)saveConfigForKey:(NSString *)key value:(NSString *)value {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}
//
+ (NSString *) configForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
//
+ (void) battleFrontSaveProfile:(SSRProfile *)profile {
    if (profile == nil) {
        return;
    }
    
    [ShadowsocksRunner saveConfigForKey:kShadowsocksRemarksKey value:profile.remarks];
    
    [ShadowsocksRunner saveConfigForKey:kShadowsocksIPKey value:profile.server];
    [ShadowsocksRunner saveConfigForKey:kShadowsocksPortKey value:[NSString stringWithFormat:@"%ld", (long)profile.serverPort]];
    [ShadowsocksRunner saveConfigForKey:kShadowsocksPasswordKey value:profile.password];
    [ShadowsocksRunner saveConfigForKey:kShadowsocksEncryptionKey value:profile.method];
    
    [ShadowsocksRunner saveConfigForKey:kShadowsocksProtocolKey value:profile.protocol];
    [ShadowsocksRunner saveConfigForKey:kShadowsocksProtocolParamKey value:profile.protocolParam];
    [ShadowsocksRunner saveConfigForKey:kShadowsocksObfsKey value:profile.obfs];
    [ShadowsocksRunner saveConfigForKey:kShadowsocksObfsParamKey value:profile.obfsParam];
    
    [ShadowsocksRunner saveConfigForKey:kShadowsocksOtEnableKey value:[NSString stringWithFormat:@"%ld", (long)profile.ot_enable]];
    [ShadowsocksRunner saveConfigForKey:kShadowsocksOtDomainKey value:profile.ot_domain];
    [ShadowsocksRunner saveConfigForKey:kShadowsocksOtPathKey value:profile.ot_path];
}


//获取当前所选SSR节点配置
+ (SSRProfile *)getCurrentNodeProfile {
    SSRProfile *profile = [[SSRProfile alloc] init];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *selectedNode = [defaults dictionaryForKey:@"OC_SSR_SELECTED_CONFIG"];
    if (selectedNode != NULL){
        profile.server = selectedNode[@"ServerHost"];
        profile.serverPort = [selectedNode[@"ServerPort"] intValue];
        profile.password = selectedNode[@"Password"];
        profile.method =selectedNode[@"Method"];
        profile.remarks = selectedNode[@"Remark"];
        
        profile.protocol = selectedNode[@"ssrProtocol"];
        profile.protocolParam = selectedNode[@"ssrProtocolParam"];
        profile.obfs = selectedNode[@"ssrObfs"];
        profile.obfsParam = selectedNode[@"ssrObfsParam"];
        
        profile.ot_enable = NO;
        profile.ot_domain = @""; //实际用作ws-host
        profile.ot_path = @"";//实际用作ws-path 这2项不为空说明需要走ws协议
    }
    return profile;
}

+(void)runTrojan{
    [[TrojanManager sharedManager] startTrojan];
}

+(void)stopTrojan{
    [[TrojanManager sharedManager] stopTrojan];
}

@end
