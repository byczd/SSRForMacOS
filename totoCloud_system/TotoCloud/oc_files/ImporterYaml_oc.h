//
//  ImporterYaml_oc.h
//  totoCloud
//
//  Created by 黄龙 on 2022/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Importer_oc : NSObject
//-(void)loadYamlfile:(NSString *)file;
//+(void)doyamlTest:(NSString *)file;
//- (void)testReadData;

-(NSArray *)loadYamlData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
