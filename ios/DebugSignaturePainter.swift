//
//  DebugSignaturePainter.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/31/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

final class DebugLine: Line {
    private let updateDirtyRect: UpdateDirtyRect

    init(updateDirtyRect: @escaping UpdateDirtyRect) {
        self.updateDirtyRect = updateDirtyRect
    }
    
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
        context.addArc(center: point.position, radius: 3, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        context.fillPath()
        context.restoreGState()
    }
}

/// Simple signature painter for drawing debug information
final class DebugSignaturePainter: SignaturePainter {
    var updateDirtyRect: UpdateDirtyRect?

    func addLine() -> Line {
        return DebugLine(updateDirtyRect: onUpdateDirtyRect)
    }

    private func onUpdateDirtyRect(rect: CGRect) {
        updateDirtyRect?(rect)
    }
}
