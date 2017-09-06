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
         UIImage *uiImage = nil;
         @try {
             uiImage = [UIImage imageWithCGImage:image];
         } @finally {
             CGImageRelease(image);
         }
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             NSData *imageData = UIImagePNGRepresentation(uiImage);
             if ([method isEqualToString:@"base64"]) {
                 NSString *base64String = [imageData base64EncodedStringWithOptions:0];
                 resolve(base64String);
             } else if ([method isEqualToString:@"file"]) {
                 if (!details) {
                     reject(@"details-missing", @"Need to provide details for file method", nil);
                     return;
                 }
                 NSString *path = details[@"path"];
                 if (!path) {
                     reject(@"path-missing", @"path is missing in details for file method", nil);
                     return;
                 }
                 NSError *error = nil;
                 [imageData writeToURL:[NSURL fileURLWithPath:path] options:NSDataWritingAtomic error:&error];
                 if (!error) {
                     resolve([NSNull null]);
                 } else {
                     reject(@"write-file-error", @"Fail to write file", error);
                 }
             } else {
                 reject(
                    @"bad-method",
                    [NSString stringWithFormat:@"Unsupported method %@", method],
                    nil
                );
             }
         });
     }];
}

- (UIView *)view {
    return [[SignaturePadWrapper alloc] init];
}

@end
