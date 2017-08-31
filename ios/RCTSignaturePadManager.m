#import "RCTSignaturePadManager.h"
#import "SignaturePad.h"

@implementation RCTSignaturePadManager

RCT_EXPORT_MODULE()

- (UIView *)view {
  return [[SignaturePad alloc] init];
}

@end
