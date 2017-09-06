//
//  SignaturePad.m
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import "SignaturePad.h"
#import "FrozenCanvas.h"
#import "SignaturePainter.h"
#import "SmoothPainter.h"

@implementation SignaturePad {
    FrozenCanvas *canvas;
    id<SignaturePainter> painter;
    NSMutableDictionary<NSValue *, id<Line>> *lines;
    NSValue *dirtyRect;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self initPad];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initPad];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initPad];
    }
    return self;
}

- (void) dealloc {
    [self removeObserver:self forKeyPath:@"frame"];
}

- (void) initPad {
    dirtyRect = nil;
    painter = [SmoothPainter new];
    __weak SignaturePad *weakSelf = self;
    painter.updateDirtyRect = ^(CGRect rect) {
        if (weakSelf) {
            [weakSelf onUpdateDirtyRect:rect];
        }
    };
    canvas = [[FrozenCanvas alloc] initWithSize:self.frame.size scale:[UIScreen mainScreen].scale];
    lines = [NSMutableDictionary dictionary];
    [self addObserver:self forKeyPath:@"frame" options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        FrozenCanvas *oldCanvas = canvas;
        canvas = [[FrozenCanvas alloc] initWithSize:self.frame.size scale:[UIScreen mainScreen].scale];
        if (oldCanvas) {
            CGPoint origin = CGPointMake(
                (self.frame.size.width / 2) - (oldCanvas.size.width / 2),
                (self.frame.size.height / 2) - (oldCanvas.size.height / 2)
            );
            [canvas drawOnTop:^(CGContextRef context) {
                CGContextDrawImage(
                    context,
                    CGRectMake(
                        origin.x,
                        origin.y,
                        oldCanvas.size.width,
                        oldCanvas.size.height
                    ),
                    oldCanvas.snapshot
                );
            }];
        }
    }
}

// MARK: Handle drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // For debugging update rect
    /*
    if (!CGRectContainsRect(rect, self.bounds)) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor);
        CGContextAddRect(context, rect);
        CGContextFillPath(context);
    }*/
    CGContextDrawImage(context, self.bounds, canvas.snapshot);
}

- (void)onUpdateDirtyRect:(CGRect)rect {
    if (!dirtyRect) {
        dirtyRect = [NSValue valueWithCGRect:rect];
        return;
    }
    dirtyRect = [NSValue valueWithCGRect:CGRectUnion(dirtyRect.CGRectValue, rect)];
}

- (void)updateNeedsDisplay {
    if (dirtyRect) {
        [self setNeedsDisplayInRect:dirtyRect.CGRectValue];
        dirtyRect = nil;
    }
}

// MARK: Handle touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [canvas drawOnTop:^(CGContextRef context) {
        for (UITouch *touch in touches) {
            // do not process touches from subviews
            if (touch.view != self) {
                continue;
            }

            LinePoint point = [SignaturePad pointForTouch:touch];
            id<Line> line = [painter addLine];
            NSValue *key = [SignaturePad keyForTouch:touch];
            lines[key] = line;

            [line addPoint:point type:PointStart context:context];
        }
    }];
    [self updateNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [canvas drawOnTop:^(CGContextRef context) {
        for (UITouch *touch in touches) {
            // do not process touches from subviews
            if (touch.view != self) {
                continue;
            }

            NSValue *key = [SignaturePad keyForTouch:touch];
            id<Line> line = lines[key];

            NSArray<UITouch *> *coalescedTouches = [event coalescedTouchesForTouch:touch];
            for (UITouch *coalescedTouch in coalescedTouches) {
                LinePoint point = [SignaturePad pointForTouch:coalescedTouch];
                [line addPoint:point type:PointBetween context:context];
            }
        }
    }];
    [self updateNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [canvas drawOnTop:^(CGContextRef context) {
        for (UITouch *touch in touches) {
            // do not process touches from subviews
            if (touch.view != self) {
                continue;
            }

            NSValue *key = [SignaturePad keyForTouch:touch];
            id<Line> line = lines[key];

            NSArray<UITouch *> *coalescedTouches = [event coalescedTouchesForTouch:touch];
            for (UITouch *coalescedTouch in coalescedTouches) {
                LinePoint point = [SignaturePad pointForTouch:coalescedTouch];
                [line addPoint:point type:PointEnd context:context];
            }

            [lines removeObjectForKey:key];
        }
    }];
    [self updateNeedsDisplay];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

+ (NSValue *)keyForTouch:(UITouch *)touch {
    // TODO: not sure if this is the best way to track UITouch
    return [NSValue valueWithPointer:(__bridge const void * _Nullable)(touch)];
}

+ (struct LinePoint)pointForTouch:(UITouch *)touch {
    struct LinePoint point;
    point.position = [touch preciseLocationInView:touch.view];
    point.timestamp = touch.timestamp;
    point.stylus = touch.type == UITouchTypeStylus;
    point.force = touch.force;
    point.altitudeAngle = touch.altitudeAngle;
    point.azimuthAngle = [touch azimuthAngleInView:touch.view];
    return point;
}

@end
