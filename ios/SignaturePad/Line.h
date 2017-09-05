//
//  Line.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinePoint.h"

typedef NS_ENUM(NSInteger, PointType) {
    PointStart,
    PointBetween,
    PointEnd
};

@protocol Line

/// Add point to the line
- (void) addPoint:(LinePoint)point type:(PointType)type context:(CGContextRef)context ;

@end
