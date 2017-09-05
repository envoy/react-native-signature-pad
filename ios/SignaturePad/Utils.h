//
//  Utils.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// Get the vector between two points
static CGVector CGVectorBetween(const CGPoint p0, const CGPoint p1) {
    return CGVectorMake(p1.x - p0.x, p1.y - p0.y);
}

/// Get length of vector
static CGFloat CGVectorLength(const CGVector vector) {
    return sqrt((vector.dx * vector.dx) + (vector.dy * vector.dy));
}

/// Get CGRect by expanding given size around the point
static CGRect CGPointDirtyRect(const CGPoint point, const CGFloat size) {
    return CGRectMake(
      point.x - size,
      point.y - size,
      size * 2,
      size * 2
  );
}
