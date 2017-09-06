//
//  SignaturePad.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateSignatureBlock)(CGFloat count, CGFloat length);

@interface SignaturePad : UIView

// Lowpass velocity filter factor
@property CGFloat velocityFilterWeight;
// Minimum stroke width
@property CGFloat minWidth;
// Maximum stroke width
@property CGFloat maxWidth;
// The minimum number to be consider too close
@property CGFloat minDistance;
// Color of stroke
@property (nonnull) UIColor *color;
// Callback block called when signature updated
@property (nullable) UpdateSignatureBlock signatureUpdate;
// Current total length of signature stroke
@property (readonly, getter=getSignatureLength) CGFloat signatureLength;
// Current total number of line counts
@property (readonly) CGFloat lineCount;

/// Clear signature pad
- (void)clear;

@end
