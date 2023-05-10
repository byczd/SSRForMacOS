//
//  ProxyConfHelper.m
//  totoCloud
//
//  Created by cxjdfb on 2020/5/3.
//  Copyright © 2020 cxjdfb. All rights reserved.
//

#import "ProxyConfHelper.h"
#import "OC_Config.h"

#define kTrojanHelper @"/Library/Application Support/tqqCloud/ProxyConfHelper"

#define kProxyConfHelperVersion @"1.0"

@implementation ProxyConfHelper

GCDWebServer *webServer = nil;

+ (BOOL)isVersionOk {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:kTrojanHelper];
    
    NSArray *args;
    args = [NSArray arrayWithObjects:@"-v", nil];
    [task setArguments: args];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *fd;
    fd = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [fd readDataToEndOfFile];
    
    NSString *str;
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (![str isEqualToString:kProxyConfHelperVersion]) {
        return NO;
    }
    return YES;
}

+ (void)install {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:kTrojanHelper] || ![self isVersionOk]) {
        NSString *helperPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"install_helper.sh"];
        NSLog(@"run install script: %@", helperPath);
        NSDictionary *error;
        NSString *script = [NSString stringWithFormat:@"do shell script \"bash %@\" with administrator privileges", helperPath];
        NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
        if ([appleScript executeAndReturnError:&error]) {
            NSLog(@"installation success");
        } else {
            NSLog(@"installation failure"); //NSAppleScriptErrorMessage：管理员用户名或密码不正确。
        }
    }
}

//通过ProxyConfHelper程序带相应参数配置系统网络"高级"里的代理设置
+ (void)callHelper:(NSArray*) arguments {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:kTrojanHelper]; // /Library/Application Support/tqqCloud/ProxyConfHelper
    
    // this log is very important
    NSLog(@"run Trojan helper: %@ %@", kTrojanHelper, arguments);
    [task setArguments:arguments];

    NSPipe *stdoutpipe;
    stdoutpipe = [NSPipe pipe];
    [task setStandardOutput:stdoutpipe];

    NSPipe *stderrpipe;
    stderrpipe = [NSPipe pipe];
    [task setStandardError:stderrpipe];

    NSFileHandle *file;
    file = [stdoutpipe fileHandleForReading];

    [task launch];

    NSData *data;
    data = [file readDataToEndOfFile];

    NSString *string;
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (string.length > 0) {
        NSLog(@"%@", string);
    }

    file = [stderrpipe fileHandleForReading];
    data = [file readDataToEndOfFile];
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (string.length > 0) {
        NSLog(@"%@", string);
    }
}

+ (void)addArguments4ManualSpecifyNetworkServices:(NSMutableArray*) args {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:USERDEFAULTS_AUTO_CONFIGURE_NETWORK_SERVICES]) {
        NSArray* serviceKeys = [defaults arrayForKey:USERDEFAULTS_PROXY4_NETWORK_SERVICES];
        if (serviceKeys) {
            for (NSString* key in serviceKeys) {
                [args addObject:@"--network-service"];
                [args addObject:key];
            }
        }
    }
}

//pac自动代理模式,效果为：配置网络>高级>代理 勾选自动代理配置，代理配置文件url：http://127.0.0.1:8090/proxy.pac
+ (void)enablePACProxy:(NSString*) PACFilePath {
    //start server here and then using the string next line
    //next two lines can open gcdwebserver and work around pac file
    NSString *PACURLString = [self startPACServer: PACFilePath];//hi 可以切换成定制pac文件路径来达成使用定制文件路径
    NSURL* url = [NSURL URLWithString: PACURLString];
    NSMutableArray* args = [@[@"--mode", @"auto", @"--pac-url", [url absoluteString]]mutableCopy];
//像telegram等，需要设置系统的socks5代理，然后在telegram上设置socks5代理与系统设置一致即可
    NSUInteger socks5port = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT];
    [args addObject:@"--port"];
    [args addObject:[NSString stringWithFormat:@"%lu", (unsigned long)socks5port]];
    
    [self addArguments4ManualSpecifyNetworkServices:args];
    [self callHelper:args];
}

//全局代理，效果为配置网络>高级>代理 勾选网页代理(127.0.0.1:10801)、安全网页代理(127.0.0.1:10801)、socks代理(127.0.0.1:10800)
+ (void)enableGlobalProxy {
//USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT在ssr协议下即为shadowsocksport端口
    NSUInteger port = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT]; //LocalSocks5.ListenPort    
    NSMutableArray* args = [@[@"--mode", @"global", @"--port", [NSString stringWithFormat:@"%lu", (unsigned long)port]]mutableCopy];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_LOCAL_HTTP_ON] && [[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_LOCAL_HTTP_FOLLOW_GLOBAL]) {
        NSUInteger privoxyPort = [[NSUserDefaults standardUserDefaults]integerForKey:USERDEFAULTS_LOCAL_HTTP_LISTEN_PORT]; //LocalHTTP.ListenPort

        [args addObject:@"--privoxy-port"];
        [args addObject:[NSString stringWithFormat:@"%lu", (unsigned long)privoxyPort]];
    }
    
    [self addArguments4ManualSpecifyNetworkServices:args];
    [self callHelper:args];
    [self stopPACServer];
}

//白名单代理模式
+ (void)enableWhiteListProxy {
    // 基于全局socks5代理下使用ACL文件来进行白名单代理 不需要使用pac文件
    NSUInteger port = [[NSUserDefaults standardUserDefaults]integerForKey:USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT];
    
    NSMutableArray* args = [@[@"--mode", @"global", @"--port", [NSString stringWithFormat:@"%lu", (unsigned long)port]]mutableCopy];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_LOCAL_HTTP_ON] && [[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_LOCAL_HTTP_FOLLOW_GLOBAL]) {
        NSUInteger privoxyPort = [[NSUserDefaults standardUserDefaults]integerForKey:USERDEFAULTS_LOCAL_HTTP_LISTEN_PORT];
        
        [args addObject:@"--privoxy-port"];
        [args addObject:[NSString stringWithFormat:@"%lu", (unsigned long)privoxyPort]];
    }
    
    [self addArguments4ManualSpecifyNetworkServices:args];
    [self callHelper:args];
    [self stopPACServer];
}

//取消系统网络高级里的代理配置
+ (void)disableProxy:(NSString*) PACFilePath {
    NSMutableArray* args = [@[@"--mode", @"off"]mutableCopy];
    [self addArguments4ManualSpecifyNetworkServices:args];
    [self callHelper:args];
    [self stopPACServer];
}

+ (NSString*)startPACServer:(NSString*) PACFilePath {
    //接受参数为以后使用定制PAC文件
    NSData * originalPACData;
    NSString * routerPath = @"/proxy.pac";
    if ([PACFilePath isEqual: @"hi"]) {//用默认路径来代替
        PACFilePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"/Documents/tqqCloud/gfwlist.js"];
        originalPACData = [NSData dataWithContentsOfFile: PACFilePath];
    }else{//用定制路径来代替
        originalPACData = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), @".Trojan", PACFilePath]];
        routerPath = [NSString stringWithFormat:@"/%@",PACFilePath];
    }
    [self stopPACServer];
    webServer = [[GCDWebServer alloc] init];
    [webServer addHandlerForMethod:@"GET" path: routerPath requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
        return [GCDWebServerDataResponse responseWithData: originalPACData contentType:@"application/Trojan-proxy-autoconfig"];
//    代理自动配置文件http://127.0.0.1:8090/proxy.pac，其数据内容即为/Documents/tqqCloud/gfwlist.js内容
    }];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * address = [defaults stringForKey:USERDEFAULTS_PAC_SERVER_LISTEN_ADDRESS];
    int port = (short)[defaults integerForKey:USERDEFAULTS_PAC_SERVER_LISTEN_PORT];

    [webServer startWithOptions:@{@"BindToLocalhost":@YES, @"Port":@(port)} error:nil]; //关键代理：开启代理
    return [NSString stringWithFormat:@"%@%@:%d%@",@"http://",address,port,routerPath];
}

+ (void)stopPACServer {
    if ([webServer isRunning]) {
        [webServer stop];
    }
}

@end
