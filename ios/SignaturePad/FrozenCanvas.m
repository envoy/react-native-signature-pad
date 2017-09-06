//
//  FrozenCanvas.m
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import "FrozenCanvas.h"

@implementation FrozenCanvas {
    CGContextRef context;
}

- (instancetype)initWithSize:(CGSize)size scale:(CGFloat)scale {
    self = [super init];
    if (self) {
        _size = size;
        _scale = scale;

        CGSize scaledSize = CGSizeMake(size.width * scale, size.height * scale);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        context = CGBitmapContextCreate(
            NULL,
            scaledSize.width,
            scaledSize.height,
            8,
            0,
            colorSpace,
            kCGImageAlphaPremultipliedLast
        );

        CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
        CGContextConcatCTM(context, transform);
    }
    return self;
}

- (void)dealloc {
    CGContextRelease(context);
}

- (CGImageRef) snapshot {
    return CGBitmapContextCreateImage(context);
}

- (void) drawOnTop:(void (^)(CGContextRef))block {
    CGContextSaveGState(context);
    block(context);
    CGContextRestoreGState(context);
}

@end
