#import "RNTSignaturePad.h"
#import "SignaturePad.h"

@implementation RNTSignaturePad

RCT_EXPORT_MODULE()

- (UIView *)view {
  return [[SignaturePad alloc] init];
}

@end
