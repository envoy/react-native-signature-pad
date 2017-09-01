//
//  Utils.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/1/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

struct Utils {
    /// Calculate distance from source to dest
    static func distanceFrom(src p0: CGPoint, to p1: CGPoint) -> CGFloat {
        let vector = CGVector(
            dx: p1.x - p0.x,
            dy: p1.y - p0.y
        )
        return sqrt((vector.dx * vector.dx) + (vector.dy * vector.dy))
    }

    /// Calculate dirty rect for given point
    ///  - Parameter point: point center
    ///  - Parameter size: radius of point
    static func pointDirtyRect(point: CGPoint, size: CGFloat) -> CGRect {
        return CGRect(
            origin: CGPoint(x: point.x - size, y: point.y - size),
            size: CGSize(width: size * 2, height: size * 2)
        )
    }
}
