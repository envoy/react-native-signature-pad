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
    private var lastPoint: Point!
    private var end = false

    init(width: CGFloat) {
        self.width = width
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
        // TODO: make it configurable?
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineCap(.round)
        context.beginPath()
        context.setLineWidth(width)
        context.move(to: lastPoint.position)
        context.addLine(to: point.position)
        context.strokePath()
        context.restoreGState()
        lastPoint = point
    }
}

/// Simple signature painter for drawing signature with the most stupid way, mainly for development
/// and testing purpose only
final class SimpleSignaturePainter: SignaturePainter {
    private let width: CGFloat

    init(width: CGFloat = 5) {
        self.width = width
    }
    
    func addLine() -> Line {
        return SimpleLine(width: width)
    }
}
