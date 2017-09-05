//
//  SmoothLine.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Line.h"

@interface SmoothLine : NSObject<Line>

@property CGFloat velocityFilterWeight;
@property CGFloat minWidth;
@property CGFloat maxWidth;
@property CGFloat minDistance;
@property UIColor *color;

@end
