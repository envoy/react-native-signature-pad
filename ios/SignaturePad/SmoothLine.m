//
//  SmoothLine.m
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import "SmoothLine.h"
#import "Bezier.h"
#import "Utils.h"

struct WidthTuple {
    CGFloat startWidth;
    CGFloat endWidth;
};
typedef struct WidthTuple WidthTuple;

struct ControlPointTuple {
    CGPoint control1;
    CGPoint control2;
};
typedef struct ControlPointTuple ControlPointTuple;

@implementation SmoothLine {
    NSMutableArray<NSValue *> *linePoints;
    CGFloat lastVelocity;
    CGFloat lastWidth;
    UpdateDirtyRectBlock updateDirtyRect;
    BOOL ended;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _velocityFilterWeight = 0.7;
        _minWidth = 0.5;
        _maxWidth = 2.5;
        _minDistance = 0.001;
        _color = [UIColor blackColor];
        ended = NO;
        lastVelocity = 0;
        lastWidth = _minWidth;
        linePoints = [NSMutableArray array];
    }
    return self;
}

- (instancetype) initWithUpdateDirtyRectBlock:(UpdateDirtyRectBlock)block {
    self = [self init];
    if (self) {
        updateDirtyRect = block;
    }
    return self;
}

- (void)addPoint:(LinePoint)point type:(PointType)type context:(CGContextRef)context {
    if (type == PointStart && linePoints.count) {
        return;
    }
    if (type == PointEnd) {
        if (ended) {
            return;
        }
        ended = YES;
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
    NSMutableArray<NSValue *> *cgPoints = [NSMutableArray arrayWithCapacity:4];
    NSUInteger i = 0;
    for (NSValue *value in linePoints) {
        [value getValue:&points[i]];
        [cgPoints addObject:[NSValue valueWithCGPoint:points[i].position]];
        ++i;
    }

    LinePoint startPoint = points[1];
    LinePoint endPoint = points[2];

    WidthTuple widths = [self calculateCurveWidthsForStartPoint:startPoint endPoint:endPoint];

    // check distance among all points, if we see too close, draw it with simple line instead
    // as calculateCurveControlPoints cannot fit them
    BOOL tooClose = [self pointsTooClose: cgPoints];

    // points are not too close, draw as curve
    if (!tooClose) {
        CGPoint c2 = [self calculateCurveControlPoints:points[0].position
                                                    s2:points[1].position
                                                    s3:points[2].position].control2;
        CGPoint c3 = [self calculateCurveControlPoints:points[1].position
                                                    s2:points[2].position
                                                    s3:points[3].position].control1;
        Bezier *curve = [[Bezier alloc] initWithStartPoint:startPoint.position
                                                  endPoint:endPoint.position
                                                  control1:c2
                                                  control2:c3];
        [self drawCurveLineWithContext:context
                                 curve:curve
                            startWidth:widths.startWidth
                              endWidth:widths.endWidth];
    // looks like the point is too close, let's draw a striaght line
    } else {
        [self drawStraightLineWithContext:context
                               startPoint:startPoint.position
                                 endPoint:endPoint.position
                               startWidth:widths.startWidth
                                 endWidth:widths.endWidth];
    }


    CGContextRestoreGState(context);

    // calculate dirty rect
    CGFloat safeWidth = fmax(widths.startWidth, widths.endWidth);
     // enlarge the dirty rect a little bit to make it safer
    CGRect dirtyRect = CGRectInset(
        CGRectUnion(
            CGPointDirtyRect(startPoint.position, safeWidth),
            CGPointDirtyRect(endPoint.position, safeWidth)
        ),
        -10, -10
    );

    if (updateDirtyRect) {
        updateDirtyRect(dirtyRect);
    }

    // remove first point, keep only 3 in points, so that when the next point comes in, there
    // will be 4 to draw
    [linePoints removeObjectAtIndex:0];
}

- (void)drawStraightLineWithContext:(CGContextRef)context
                         startPoint:(CGPoint)startPoint
                           endPoint:(CGPoint)endPoint
                         startWidth:(CGFloat)startWidth
                           endWidth:(CGFloat)endWidth
{
    CGVector vector = CGVectorBetween(startPoint, endPoint);
    NSUInteger steps = fmax(CGVectorLength(vector), 1);
    [self drawLineWithContext:context
                        steps:steps
                   startWidth:startWidth
                     endWidth:endWidth
                     lineFunc:^CGPoint(CGFloat time) {
        return CGPointMake(
           startPoint.x + vector.dx * time,
           startPoint.y + vector.dy * time
       );
    }];
}

- (void)drawCurveLineWithContext:(CGContextRef)context
                           curve:(Bezier *)curve
                      startWidth:(CGFloat)startWidth
                        endWidth:(CGFloat)endWidth
{
    NSUInteger steps = fmax([curve approximatedLengthWithSteps:10], 1);
    [self drawLineWithContext:context
                        steps:steps
                   startWidth:startWidth
                     endWidth:endWidth
                     lineFunc:^CGPoint(CGFloat time) {
                         return [curve pointAtTime:time];
                     }];
}

- (void)drawLineWithContext:(CGContextRef)context
                      steps:(NSUInteger)steps
                 startWidth:(CGFloat)startWidth
                   endWidth:(CGFloat)endWidth
                   lineFunc:(CGPoint (^)(CGFloat))lineFunc
{
    CGFloat widthDelta = endWidth - startWidth;
    NSUInteger drawSteps = floor(steps) * 2;
    for (NSUInteger i = 0; i < drawSteps; ++i) {
        CGFloat t = i / (CGFloat)drawSteps;
        CGFloat ttt = t * t * t;
        CGPoint point = lineFunc(t);
        // TODO: hmmm, not sure why t ^ 3 instead of just t?
        CGFloat width = startWidth + (ttt * widthDelta);
        CGContextAddArc(context, point.x, point.y, width, 0, M_PI * 2, false);
        CGContextFillPath(context);
    }
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

/// Determine if given points in a line, along the line, any pair of them is too close
// (less than minDistance)
- (BOOL)pointsTooClose:(NSArray<NSValue *> *)points {
    CGPoint previousPoint;
    [points[0] getValue:&previousPoint];
    for (NSValue *value in [points subarrayWithRange:NSMakeRange(1, points.count - 1)]) {
        CGPoint currentPoint;
        [value getValue:&currentPoint];
        CGVector vector = CGVectorBetween(previousPoint, currentPoint);
        CGFloat distance = CGVectorLength(vector);
        if (distance < self.minDistance) {
            return YES;
        }
        previousPoint = currentPoint;
    }
    return NO;
}

/// Calculate Bezier curve control points for given 3 points
/// implementation references to
// https://github.com/szimek/signature_pad/blob/master/src/signature_pad.js#L267-L292
- (ControlPointTuple) calculateCurveControlPoints:(CGPoint)s1 s2:(CGPoint)s2 s3:(CGPoint)s3 {
    CGFloat dx1 = s1.x - s2.x;
    CGFloat dy1 = s1.y - s2.y;
    CGFloat dx2 = s2.x - s3.x;
    CGFloat dy2 = s2.y - s3.y;

    CGPoint m1 = CGPointMake(
        (s1.x + s2.x) / 2.0,
        (s1.y + s2.y) / 2.0
    );
    CGPoint m2 = CGPointMake(
        (s2.x + s3.x) / 2.0,
        (s2.y + s3.y) / 2.0
    );

    CGFloat l1 = sqrt((dx1 * dx1) + (dy1 * dy1));
    CGFloat l2 = sqrt((dx2 * dx2) + (dy2 * dy2));

    CGFloat dxm = m1.x - m2.x;
    CGFloat dym = m1.y - m2.y;

    CGFloat k = l2 / (l1 + l2);
    CGPoint cm = CGPointMake(
        m2.x + (dxm * k),
        m2.y + (dym * k)
    );

    CGFloat tx = s2.x - cm.x;
    CGFloat ty = s2.y - cm.y;

    ControlPointTuple tuple;
    tuple.control1 = CGPointMake(m1.x + tx, m1.y + ty);
    tuple.control2 = CGPointMake(m2.x + tx, m2.y + ty);
    return tuple;
}



/// Calculate velocity from source to dest
+ (CGFloat)velocityFrom:(LinePoint)p0 to:(LinePoint)p1 {
    NSTimeInterval timeDelta = p1.timestamp - p0.timestamp;
    CGVector vector = CGVectorBetween(p0.position, p1.position);
    CGFloat distance = CGVectorLength(vector);
    return distance / timeDelta;
}

@end
