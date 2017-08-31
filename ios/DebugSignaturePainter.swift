//
//  DebugSignaturePainter.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/31/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

final class DebugLine: Line {
    func start(context: CGContext, point: Point) {
        drawPoint(context: context, point: point, color: UIColor.green)
    }

    func add(context: CGContext, point: Point) {
        drawPoint(context: context, point: point, color: UIColor.yellow)
    }

    func end(context: CGContext, point: Point) {
        drawPoint(context: context, point: point, color: UIColor.red)
    }

    private func drawPoint(context: CGContext, point: Point, color: UIColor) {
        context.saveGState()
        context.setFillColor(color.cgColor)
        context.beginPath()
        context.addArc(center: point.position, radius: 3, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        context.fillPath()
        context.restoreGState()
    }
}

/// Simple signature painter for drawing debug information
final class DebugSignaturePainter: SignaturePainter {
    func addLine() -> Line {
        return DebugLine()
    }
}
