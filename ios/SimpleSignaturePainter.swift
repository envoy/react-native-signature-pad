//
//  SimpleSignaturePainter.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/31/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

final class SimpleLine: Line {
    private let width: CGFloat
    private let color: UIColor
    private var lastPoint: Point!
    private var end = false
    private let updateDirtyRect: UpdateDirtyRect

    init(updateDirtyRect: @escaping UpdateDirtyRect, color: UIColor, width: CGFloat) {
        self.width = width
        self.color = color
        self.updateDirtyRect = updateDirtyRect
    }

    func start(context: CGContext, point: Point) {
        guard lastPoint == nil else {
            return
        }
        lastPoint = point
    }

    func add(context: CGContext, point: Point) {
        drawPoint(context: context, point: point)
    }

    func end(context: CGContext, point: Point) {
        guard !end else {
            return
        }
        drawPoint(context: context, point: point)
        end = true
    }

    private func drawPoint(context: CGContext, point: Point) {
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineCap(.round)
        context.beginPath()
        context.setLineWidth(width)
        context.move(to: lastPoint.position)
        context.addLine(to: point.position)
        context.strokePath()
        context.restoreGState()

        let dirtyRect = Utils.pointDirtyRect(point: lastPoint.position, size: width)
            .union(Utils.pointDirtyRect(point: point.position, size: width))
            // enlarge dirty rect a little bit to be safe
            .insetBy(dx: -5, dy: -5)
        updateDirtyRect(dirtyRect)

        lastPoint = point
    }
}

/// Simple signature painter for drawing signature with the most stupid way, mainly for development
/// and testing purpose only
final class SimpleSignaturePainter: SignaturePainter {
    var color = UIColor.black
    /// Callback will be called when painter update a region and mark it as dirty
    /// (needs to be redrew)
    var updateDirtyRect: UpdateDirtyRect?

    private let width: CGFloat

    init(width: CGFloat = 5) {
        self.width = width
    }
    
    func addLine() -> Line {
        return SimpleLine(
            updateDirtyRect: onUpdateDirtyRect,
            color: color,
            width: width
        )
    }

    private func onUpdateDirtyRect(rect: CGRect) {
        updateDirtyRect?(rect)
    }
}
