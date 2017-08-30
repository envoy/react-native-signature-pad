#import "RCTSignaturePad.h"
#import "SignaturePad.h"

@implementation RCTSignaturePad

RCT_EXPORT_MODULE()

- (UIView *)view {
  return [[SignaturePad alloc] init];
}

@end
