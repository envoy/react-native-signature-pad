#import <UIKit/UIKit.h>

#import "RCTSignaturePadManager.h"
#import "SignaturePadWrapper.h"

@implementation RCTSignaturePadManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(velocityFilterWeight, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(minWidth, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(maxWidth, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(minDistance, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(color, UIColor)
RCT_EXPORT_VIEW_PROPERTY(onUpdate, RCTBubblingEventBlock)

- (UIView *)view {
  return [[SignaturePadWrapper alloc] init];
}

@end
