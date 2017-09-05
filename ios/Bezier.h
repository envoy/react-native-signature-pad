//
//  Bezier.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Bezier : NSObject

@property (readonly) CGPoint startPoint;
@property (readonly) CGPoint endPoint;
@property (readonly) CGPoint control1;
@property (readonly) CGPoint control2;

- (instancetype) initWithStartPoint:(CGPoint)startPoint
                           endPoint:(CGPoint)endPoint
                           control1:(CGPoint)control1
                           control2:(CGPoint)control2;

/// Calculate approximated length of bezier curve
///  - Parameter steps: how many steps to divide the curve into segments and calculate the
///                      length, bigger number means more accurate but also slower
- (CGFloat) approximatedLengthWithSteps: (CGFloat)steps;

/// Calculate point of this bezier curve at given time
///  - Parameter atTime: time for calculating the point on Bezier curve
- (CGPoint) pointAtTime: (CGFloat)time;

@end
