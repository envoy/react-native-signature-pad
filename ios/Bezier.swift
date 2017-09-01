//
//  Bezier.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/1/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

/// Struct for Bezier curve, implementation mainly reference to
/// https://github.com/szimek/signature_pad/blob/master/src/bezier.js
struct Bezier {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let control1: CGPoint
    let control2: CGPoint

    /// Calculate approximated length of bezier curve
    ///  - Parameter steps: how many steps to divide the curve into segments and calculate the
    ///                      length, bigger number means more accurate but also slower
    func approximatedLength(steps: UInt = 10) -> CGFloat {
        var length: CGFloat = 0
        var previousPoint = point(atTime: 0)
        for i in 1...steps {
            let t = i / steps
            let currentPoint = point(atTime: CGFloat(t))
            length += Utils.distanceFrom(src: previousPoint, to: currentPoint)
            previousPoint = currentPoint
        }
        return length
    }

    /// Calculate point of this bezier curve at given time
    ///  - Parameter atTime: time for calculating the point on Bezier curve
    func point(atTime t: CGFloat) -> CGPoint {
        let x = (      startPoint.x * (1.0 - t) * (1.0 - t)  * (1.0 - t))
             + (3.0 *  control1.x   * (1.0 - t) * (1.0 - t)  * t)
             + (3.0 *  control2.x   * (1.0 - t) * t          * t)
             + (       endPoint.x   * t         * t          * t)
        let y = (      startPoint.y * (1.0 - t) * (1.0 - t)  * (1.0 - t))
             + (3.0 *  control1.y   * (1.0 - t) * (1.0 - t)  * t)
             + (3.0 *  control2.y   * (1.0 - t) * t          * t)
             + (       endPoint.y   * t         * t          * t)
        return CGPoint(x: x, y: y)
    }

}
