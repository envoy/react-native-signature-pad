//
//  SmoothSignaturePainter.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/31/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

final class SmoothLine: Line {
    var velocityFilterWeight: CGFloat = 0.7
    var minWidth: CGFloat = 0.5
    var maxWidth: CGFloat = 2.5
    var minDistance: CGFloat = 0.001

    private let updateDirtyRect: UpdateDirtyRect
    private var points: [Point] = []
    private var end = false

    private var lastVelocity: CGFloat = 0
    private var lastWidth: CGFloat = 0.5

    private let color: UIColor

    init(updateDirtyRect: @escaping UpdateDirtyRect, color: UIColor) {
        self.updateDirtyRect = updateDirtyRect
        self.color = color
    }

    func start(context: CGContext, point: Point) {
        guard points.count == 0 else {
            return
        }
        addPoint(context: context, point: point)
    }

    func add(context: CGContext, point: Point) {
        addPoint(context: context, point: point)
    }

    func end(context: CGContext, point: Point) {
        guard !end else {
            return
        }
        addPoint(context: context, point: point)
        end = true
    }

    private func addPoint(context: CGContext, point: Point) {
        points.append(point)
        drawPoints(context: context)
    }

    private func drawPoints(context: CGContext) {
        guard points.count >= 4 else {
            return
        }
        context.saveGState()
        context.setFillColor(color.cgColor)

        let widths = calculateCurveWidths(startPoint: points[1], endPoint: points[2])

        // check distance among all points, if we see too close, draw it with simple line instead
        // as calculateCurveControlPoints cannot fit them
        let distances = zip(points[0..<points.count - 1], points[1..<points.count])
            .map({ (lhs, rhs) -> CGFloat in
                return Utils.distanceFrom(src: lhs.position, to: rhs.position)
            })
        var tooClose = false
        for distance in distances {
            if distance < minDistance {
                tooClose = true
                break
            }
        }

        // points are not too close, draw as curve
        let startPoint = points[1].position
        let endPoint = points[2].position
        if !tooClose {
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
            let curve = Bezier(
                startPoint: startPoint,
                endPoint: endPoint,
                control1: c2,
                control2: c3
            )
            let steps = max(curve.approximatedLength(), 1)
            drawCruve(
                context: context,
                steps: steps,
                startWidth: widths.0,
                endWidth: widths.1,
                lineFunc: curve.point
            )
        // looks like the point is too close, let's draw a striaght line
        } else {
            let dx = endPoint.x - startPoint.x
            let dy = endPoint.y - startPoint.y
            let steps = max(Utils.distanceFrom(src: startPoint, to: endPoint), 1)
            drawCruve(
                context: context,
                steps: steps,
                startWidth: widths.0,
                endWidth: widths.1
            ) { (atTime: CGFloat) -> CGPoint in
                return CGPoint(
                    x: startPoint.x + dx * atTime,
                    y: startPoint.y + dy * atTime
                )
            }
        }
        context.restoreGState()

        // calculate dirty rect
        let safeWidth = max(widths.0, widths.1)
        let dirtyRect = Utils
            .pointDirtyRect(point: startPoint, size: safeWidth)
            .union(Utils.pointDirtyRect(point: endPoint, size: safeWidth))
            // enlarge the dirty rect a little bit to make it safer
            .insetBy(dx: -10, dy: -10)
        updateDirtyRect(dirtyRect)

        // remove first point, keep only 3 in points, so that when the next point comes in, there
        // will be 4 to draw
        points.removeFirst()
    }

    // Draw a curve with startWidth as the initial and change over time to endWidth as the
    // final width
    private func drawCruve(
        context: CGContext,
        steps: CGFloat,
        startWidth: CGFloat,
        endWidth: CGFloat,
        lineFunc: ((_ atTime: CGFloat) -> CGPoint)
    ) {
        let widthDelta = endWidth - startWidth
        let drawSteps = UInt(floor(steps)) * 2
        for i in 0 ..< drawSteps {
            let t = CGFloat(i) / CGFloat(drawSteps)
            let ttt = t * t * t
            let point = lineFunc(t)
            // TODO: hmmm, not sure why t ^ 3 instead of just t?
            let width = startWidth + (ttt * widthDelta)
            context.addArc(
                center: point,
                radius: width,
                startAngle: 0,
                endAngle: 2 * CGFloat.pi,
                clockwise: false
            )
            context.fillPath()
        }
    }

    private func calculateCurveWidths(startPoint: Point, endPoint: Point) -> (CGFloat, CGFloat) {
        let newVelocity = SmoothLine.velocityFrom(src: startPoint, to: endPoint) / 1000
        // A simple lowpass filter to mitigate velocity aberrations.
        let velocity = (
            (velocityFilterWeight * newVelocity) +
            (1 - velocityFilterWeight) * lastVelocity
        )
        let effectiveForce = endPoint.stylus ? endPoint.force : 1
        let newWidth = strokeWidth(velocity: velocity, force: effectiveForce)
        let result: (CGFloat, CGFloat) = (lastWidth, newWidth)
        lastVelocity = velocity
        lastWidth = newWidth
        return result
    }

    private func strokeWidth(velocity: CGFloat, force: CGFloat) -> CGFloat {
        return max((maxWidth / (velocity + 1)) * force, minWidth)
    }

    /// Calculate velocity from source to dest
    static func velocityFrom(src p0: Point, to p1: Point) -> CGFloat {
        let timeDelta = p1.timestamp - p0.timestamp
        let distance = Utils.distanceFrom(src: p0.position, to: p1.position)
        return distance / CGFloat(timeDelta)
    }

    /// Calculate Bezier curve control points for given 3 points
    /// implementation references to
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
    var color = UIColor.black
    var updateDirtyRect: UpdateDirtyRect?
    
    func addLine() -> Line {
        return SmoothLine(updateDirtyRect: onUpdateDirtyRect, color: color)
    }

    private func onUpdateDirtyRect(rect: CGRect) {
        updateDirtyRect?(rect)
    }
}
