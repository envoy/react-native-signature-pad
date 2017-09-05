//
//  FrozenCanvas.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FrozenCanvas : NSObject

@property (readonly) CGSize size;
@property (readonly) CGFloat scale;

- (instancetype)initWithSize:(CGSize)size scale:(CGFloat)scale;

/// Take a snapshot of the canvas
- (CGImageRef)snapshot;

/// Draw something on top of the canvas
- (void)drawOnTop:(void (^)(CGContextRef))block;

@end
