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

@implementation SignaturePad {
    FrozenCanvas *canvas;
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
    canvas = [[FrozenCanvas alloc] initWithSize:self.frame.size scale:[UIScreen mainScreen].scale];
    [self addObserver:self forKeyPath:@"frame" options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        canvas = [[FrozenCanvas alloc] initWithSize:self.frame.size scale:[UIScreen mainScreen].scale];
        // TODO: copy image from original canvas
    }
}

// MARK: Handle drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, canvas.snapshot);
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

        }
    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

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
