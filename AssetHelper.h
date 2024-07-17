#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AssetHelper : NSObject
+ (void)saveAsset:(AVURLAsset *)asset rate:(CGFloat)rate;
@end