

#import "TrojanManager.h"

#include "trojanconf.hpp"
#include "service.h"
#include <cstdint>
#include <string>
#include <thread>

//trojan模块要引入libboost_system.a和libboost_program_options.a库

using namespace std;

@implementation TrojanManager

static thread *trojanThread = nullptr;
static Config *trojanConfig = nullptr;
static Service *trojanService = nullptr;
//static string certPath="";

+ (TrojanManager *)sharedManager {
    static dispatch_once_t onceToken;
    static TrojanManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [TrojanManager new];
    });
    return manager;
}

static void runTrojan(const string &config)
{
    trojanConfig = new Config();
    trojanConfig->load(config);
    trojanService = new Service(*trojanConfig,"");
    trojanService->run();
}


- (void)startTrojan{
    if (trojanThread!=nullptr) {
        return;
    }
    
//    let CONFIG_PATH = NSHomeDirectory()+"/Documents/totoCloud/trojan_client.json"
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    /var/mobile/Containers/Data/PluginKitPlugin/B355C7ED-C3A7-40CE-9C9F-98F1356BC7B1/Documents
    NSString *jsontPath=[NSString stringWithFormat:@"%@/totoCloud/trojan_client.json",docPath];
//    /var/mobile/Containers/Data/PluginKitPlugin/B355C7ED-C3A7-40CE-9C9F-98F1356BC7B1/Documents/trojan_client.json
    
    if (jsontPath && [jsontPath length]>0 && [[NSFileManager defaultManager] fileExistsAtPath:jsontPath]) { //每次开启路径中7A702354-527A-45DF-AE8F-CA32C987830E值都会不一样
        string str=[jsontPath UTF8String];
        trojanThread = new thread(runTrojan,str);
    }
}

- (void)stopTrojan{
    if (trojanThread != nullptr) {
        trojanService->stop();
        trojanThread->join();
        delete trojanService;
        delete trojanConfig;
        delete trojanThread;
        trojanThread = nullptr;
    }
}



@end
