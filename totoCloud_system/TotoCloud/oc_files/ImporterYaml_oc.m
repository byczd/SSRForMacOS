//
//  Importer_oc.m
//  totoCloud
//
//  Created by 黄龙 on 2022/8/17.
//

#import "ImporterYaml_oc.h"
#import "YAML/YAMLSerialization.h"


@implementation Importer_oc

//-(void)loadYamlfile:(NSString *)file{
//    NSString *filepath=[[NSBundle mainBundle] pathForResource:@"test_clash_vmess.yaml" ofType:nil];
//}

//+(void)doyamlTest:(NSString *)file{
//
//}
//
//- (void)testReadData
//{
//    
//    NSString *fileName = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_clash_vmess" ofType:@"yaml"];
//    NSData *data = [NSData dataWithContentsOfFile:fileName];
//    NSTimeInterval before = [[NSDate date] timeIntervalSince1970];
//    NSMutableArray *yaml = [YAMLSerialization YAMLWithData: data options: kYAMLReadOptionStringScalars error: nil];
//    NSLog(@"YAMLWithData took %f", ([[NSDate date] timeIntervalSince1970] - before));
//    NSLog(@"[%d]%@",[yaml count],yaml);
//    NSDictionary *tmpfirst=yaml[0]; // [yaml[0] valueForKey:@"proxies"];
//    NSArray *proxyArr=[tmpfirst objectForKey:@"proxies"];
//    NSLog(@"proxyArr.count=%d",[proxyArr count]);
//    NSDictionary *tmpDict=[NSDictionary dictionaryWithDictionary:proxyArr[0]];
//    NSLog(@"%@",tmpDict);
////    XCTAssertEqual((int) 10, (int) [yaml count], @"Wrong number of expected objects");
//}

-(NSArray *)loadYamlData:(NSData *)data{
//    NSMutableArray *yaml = [YAMLSerialization YAMLWithData: data options: kYAMLReadOptionStringScalars error: nil];
    NSMutableArray *yaml = [YAMLSerialization objectsWithYAMLData: data options: kYAMLReadOptionStringScalars error: nil];
    NSDictionary *tmpfirst=yaml[0];
    NSArray *proxyArr=[tmpfirst objectForKey:@"proxies"]; //要确保节点组名为“proxies”
    NSLog(@"proxyArr.count=%lu",(unsigned long)[proxyArr count]);
    return proxyArr;
}



@end
