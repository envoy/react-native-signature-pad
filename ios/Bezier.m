//
//  Bezier.m
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import "Bezier.h"
#import "Utils.h"

@implementation Bezier

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint control1:(CGPoint)control1 control2:(CGPoint)control2 {
    self = [super init];
    if (self) {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _control1 = control1;
        _control2 = control2;
    }
    return self;
}

- (CGFloat) approximatedLengthWithSteps:(CGFloat)steps {
    CGFloat length = 0;
    CGPoint previousPoint = [self pointAtTime:0];
    for (NSUInteger i = 1; i <= steps; ++i) {
        CGFloat t = i / steps;
        CGPoint currentPoint = [self pointAtTime:t];
        CGVector vector = CGVectorBetween(previousPoint, currentPoint);
        length += CGVectorLength(vector);
        previousPoint = currentPoint;
    }
    return length;
}

- (CGPoint) pointAtTime:(CGFloat)t {
    CGFloat x = (     _startPoint.x * (1.0 - t) * (1.0 - t)  * (1.0 - t))
             + (3.0 * _control1.x   * (1.0 - t) * (1.0 - t)  * t)
             + (3.0 * _control2.x   * (1.0 - t) * t          * t)
             + (      _endPoint.x   * t         * t          * t);
    CGFloat y = (     _startPoint.y * (1.0 - t) * (1.0 - t)  * (1.0 - t))
             + (3.0 * _control1.y   * (1.0 - t) * (1.0 - t)  * t)
             + (3.0 * _control2.y   * (1.0 - t) * t          * t)
             + (      _endPoint.y   * t         * t          * t);
    return CGPointMake(x, y);
}

@end
