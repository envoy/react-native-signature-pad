//
//  SignaturePainter.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/31/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

struct Point {
    /// Position of the point
    let position: CGPoint
    /// Timestamp of the point
    let timestamp: TimeInterval
    /// Is this point from Apple Pencil?
    let stylus: Bool
    /// Force of the point, for Apple Pencil only
    let force: CGFloat
    /// Altitude angle of the point, for Apple Pencil only
    let altitudeAngle: CGFloat
    /// Azimuth angle of the point, for Apple Pencil only
    let azimuthAngle: CGFloat
}

protocol Line {
    /// Start the line
    func start(context: CGContext, point: Point)
    /// Add a new point to the line
    func add(context: CGContext, point: Point)
    /// End the line
    func end(context: CGContext, point: Point)
}

protocol SignaturePainter {
    /// Start a new line on the canvas
    func addLine() -> Line
}
