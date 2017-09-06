#import <UIKit/UIKit.h>
#import <React/RCTUIManager.h>

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

RCT_EXPORT_METHOD(clear:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:
     ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, SignaturePadWrapper *> *viewRegistry) {
         SignaturePadWrapper *view = viewRegistry[reactTag];
         if (!view || ![view isKindOfClass:[SignaturePadWrapper class]]) {
             RCTLogError(@"Cannot find SignaturePadWrapper with tag #%@", reactTag);
             return;
         }
         [view clear];
     }];
}

RCT_EXPORT_METHOD(capture:(nonnull NSNumber *)reactTag
                  method:(NSString *)method
                  details:(NSDictionary *)details
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:
     ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, SignaturePadWrapper *> *viewRegistry) {
         SignaturePadWrapper *view = viewRegistry[reactTag];

         if (!view || ![view isKindOfClass:[SignaturePadWrapper class]]) {
             RCTLogError(@"Cannot find SignaturePadWrapper with tag #%@", reactTag);
             return;
         }

         CGImageRef image = [view capture];
         if ([method isEqualToString:@"base64"]) {
             NSData *imageData = UIImagePNGRepresentation((__bridge UIImage * _Nonnull)(image));
             resolve([imageData base64EncodedStringWithOptions:0]);
         } else {
             NSError *error = nil;
             reject([NSString stringWithFormat:@"Unsupported method %@", method], @"", error);
         }
         CGImageRelease(image);
     }];
}

- (UIView *)view {
    return [[SignaturePadWrapper alloc] init];
}

@end
