//
//  ProxyConfHelper.h
//  totoCloud
//
//  Created by cxjdfb on 2020/5/3.
//  Copyright © 2020 cxjdfb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@interface ProxyConfHelper : NSObject

+ (BOOL)isVersionOk;

+ (void)install;

+ (void)enablePACProxy:(NSString*) PACFilePath;

+ (void)enableGlobalProxy;

+ (void)disableProxy:(NSString*) PACFilePath;

+ (NSString*)startPACServer:(NSString*) PACFilePath;

+ (void)stopPACServer;

+ (void)enableWhiteListProxy;

@end
