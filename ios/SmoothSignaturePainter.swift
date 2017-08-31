//
//  SmoothSignaturePainter.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/31/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

final class SmoothLine: Line {
    private var points: [Point] = []
    private var end = false

    func start(context: CGContext, point: Point) {
        guard points.count == 0 else {
            return
        }
        points.append(point)
    }

    func add(context: CGContext, point: Point) {
        points.append(point)
        drawCruve(context: context)
    }

    func end(context: CGContext, point: Point) {
        guard !end else {
            return
        }
        points.append(point)
        drawCruve(context: context)
        end = true
    }

    private func drawCruve(context: CGContext) {
        // TODO: also handle 3 points, make it more responsive
        guard points.count >= 4 else {
            return
        }
        context.saveGState()
        // TODO: make it configurable?
        context.setFillColor(UIColor.black.cgColor)
        context.setLineCap(.round)
        context.beginPath()

        let c2 = SmoothLine.calculateCurveControlPoints(
            s1: points[0].position,
            s2: points[1].position,
            s3: points[2].position
        ).1
        let c3 = SmoothLine.calculateCurveControlPoints(
            s1: points[1].position,
            s2: points[2].position,
            s3: points[3].position
        ).0

        context.move(to: points[0].position)
        context.addCurve(to: points[3].position, control1: c2, control2: c3)
        context.fillPath()
        context.restoreGState()

        // remove first point, keep only 3 in points, so that when the next point comes in, there
        // will be 4 to draw
        points.removeFirst()
    }

    // Calculate Bezier curve control points for given 3 points
    // implementation references to
    // https://github.com/szimek/signature_pad/blob/master/src/signature_pad.js#L267-L292
    static func calculateCurveControlPoints(s1: CGPoint, s2: CGPoint, s3: CGPoint) -> (CGPoint, CGPoint) {
        let dx1 = s1.x - s2.x
        let dy1 = s1.y - s2.y
        let dx2 = s2.x - s3.x
        let dy2 = s2.y - s3.y

        let m1 = CGPoint(
            x: (s1.x + s2.x) / 2.0,
            y: (s1.y + s2.y) / 2.0
        )
        let m2 = CGPoint(
            x: (s2.x + s3.x) / 2.0,
            y: (s2.y + s3.y) / 2.0
        )

        let l1 = sqrt((dx1 * dx1) + (dy1 * dy1))
        let l2 = sqrt((dx2 * dx2) + (dy2 * dy2))

        let dxm = (m1.x - m2.x)
        let dym = (m1.y - m2.y)

        let k = l2 / (l1 + l2)
        let cm = CGPoint(
            x: m2.x + (dxm * k),
            y: m2.y + (dym * k)
        )

        let tx = s2.x - cm.x
        let ty = s2.y - cm.y
        
        return (
            CGPoint(x: m1.x + tx, y: m1.y + ty),
            CGPoint(x: m2.x + tx, y: m2.y + ty)
        )
    }
}

/// Smooth signature painter for drawing signature with Bezier curve spline interpolation techinque
/// based on https://medium.com/square-corner-blog/smoother-signatures-be64515adb33
/// and reference implementation at https://github.com/szimek/signature_pad
final class SmoothSignaturePainter: SignaturePainter {
    func addLine() -> Line {
        return SmoothLine()
    }
}
