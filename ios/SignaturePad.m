//
//  SignaturePad.m
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/30/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import "SignaturePad.h"

@implementation SignaturePad

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // XXX:
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextMoveToPoint(context, 30, 30);
    CGContextAddLineToPoint(context, 300, 400);
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

@end
