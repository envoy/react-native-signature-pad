//
//  SmoothLine.m
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import "SmoothLine.h"
#import "Utils.h"

struct WidthTuple {
    CGFloat startWidth;
    CGFloat endWidth;
};
typedef struct WidthTuple WidthTuple;

@implementation SmoothLine {
    NSMutableArray<NSValue *> *linePoints;
    CGFloat lastVelocity;
    CGFloat lastWidth;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _velocityFilterWeight = 0.7;
        _minWidth = 0.5;
        _maxWidth = 2.5;
        _minDistance = 0.001;
        _color = [UIColor blackColor];
        lastVelocity = 0;
        lastWidth = _minWidth;
        linePoints = [NSMutableArray array];
    }
    return self;
}

- (void)addPoint:(LinePoint)point type:(PointType)type context:(CGContextRef)context {
    if (type == PointStart && linePoints.count) {
        return;
    }
    [linePoints addObject:[NSValue value:&point withObjCType:@encode(LinePoint)]];
    [self drawPointsWithContext:context];
}

- (void)drawPointsWithContext:(CGContextRef)context {
    if (linePoints.count < 4) {
        return;
    }
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.color.CGColor);

    LinePoint points[4];
    NSUInteger i = 0;
    for (NSValue *value in linePoints) {
        [value getValue:&points[i]];
        ++i;
    }

    WidthTuple widths = [self calculateCurveWidthsForStartPoint:points[1] endPoint:points[2]];
    // TODO:
    NSLog(@"xxxxx %@, %f, %f", context, widths.startWidth, widths.endWidth);

    CGContextRestoreGState(context);

    // remove first point, keep only 3 in points, so that when the next point comes in, there
    // will be 4 to draw
    [linePoints removeObjectAtIndex:0];
}

- (WidthTuple)calculateCurveWidthsForStartPoint:(LinePoint)startPoint endPoint:(LinePoint)endPoint {
    CGFloat newVelocity = [SmoothLine velocityFrom:startPoint to:endPoint] / 1000;

    // A simple lowpass filter to mitigate velocity aberrations.
    CGFloat velocity = (
        (self.velocityFilterWeight * newVelocity) +
        (1 - self.velocityFilterWeight) * lastVelocity
    );
    CGFloat effectiveForce = endPoint.stylus ? endPoint.force : 1;
    CGFloat newWidth = [self strokeWidthForVelocity:velocity force:effectiveForce];

    WidthTuple result;
    result.startWidth = lastWidth;
    result.endWidth = newWidth;

    lastVelocity = velocity;
    lastWidth = newWidth;
    return result;
}

- (CGFloat)strokeWidthForVelocity:(CGFloat)velocity force:(CGFloat)force {
    return fmax((self.maxWidth / (velocity + 1)) * force, self.minWidth);
}


/// Calculate velocity from source to dest
+ (CGFloat)velocityFrom:(LinePoint)p0 to:(LinePoint)p1 {
    NSTimeInterval timeDelta = p1.timestamp - p0.timestamp;
    CGVector vector = CGVectorBetween(p0.position, p1.position);
    CGFloat distance = CGVectorLength(vector);
    return distance / timeDelta;
}

@end
