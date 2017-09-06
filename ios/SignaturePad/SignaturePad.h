//
//  SignaturePad.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignaturePad : UIView

@property CGFloat velocityFilterWeight;
@property CGFloat minWidth;
@property CGFloat maxWidth;
@property CGFloat minDistance;
@property UIColor *color;

/// Clear signature pad
- (void)clear;

@end
