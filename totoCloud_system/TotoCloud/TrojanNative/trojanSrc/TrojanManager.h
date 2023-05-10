
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrojanManager : NSObject

+ (TrojanManager *)sharedManager;
- (void)startTrojan;
- (void)stopTrojan;
@end

NS_ASSUME_NONNULL_END
