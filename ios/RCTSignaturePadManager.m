#import <UIKit/UIKit.h>

#import "RCTSignaturePadManager.h"
#import "SignaturePad.h"

@implementation RCTSignaturePadManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(debug, BOOL)
RCT_EXPORT_VIEW_PROPERTY(velocityFilterWeight, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(minWidth, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(maxWidth, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(minDistance, CGFloat)

- (UIView *)view {
  return [[SignaturePad alloc] init];
}

@end
