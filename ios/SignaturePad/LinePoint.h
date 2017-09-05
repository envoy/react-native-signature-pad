//
//  LinePoint.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

struct LinePoint {
    /// Position of the point
    CGPoint position;
    /// Timestamp of the point
    NSTimeInterval timestamp;
    /// Is this point from Apple Pencil?
    BOOL stylus;
    /// Force of the point, for Apple Pencil only
    CGFloat force;
    /// Altitude angle of the point, for Apple Pencil only
    CGFloat altitudeAngle;
    /// Azimuth angle of the point, for Apple Pencil only
    CGFloat azimuthAngle;
};

