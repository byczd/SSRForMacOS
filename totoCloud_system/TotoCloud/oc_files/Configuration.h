// Generated by json_to_model

#import <Foundation/Foundation.h>
#import "SSRProfile.h"


@interface Configuration : NSObject

- (id)initWithJSONData:(NSData *)data;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDictionary;
- (NSData *)JSONData;


@property (nonatomic, assign) NSInteger current;

@property (nonatomic, strong) NSMutableArray<SSRProfile *> *profiles;


@end
