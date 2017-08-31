//
//  FrozenCanvas.swift
//  Board
//
//  Created by Fang-Pen Lin on 9/23/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import UIKit

/// A frozen canvas is a cached image for canvas
final class FrozenCanvas {
    let size: CGSize
    let scale: CGFloat

    var snapshot: CGImage {
        return context.makeImage()!
    }

    /// A CGContext for drawing the last representation of lines no longer receiving updates into.
    fileprivate lazy var context: CGContext = {
        var scaledSize = self.size
        scaledSize.width *= self.scale
        scaledSize.height *= self.scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let context = CGContext(
            data: nil,
            width: Int(scaledSize.width), height: Int(scaledSize.height),
            bitsPerComponent: 8, bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        context!.setLineCap(.round)
        let transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
        context!.concatenate(transform)
        return context!
    }()

    init(size: CGSize, scale: CGFloat) {
        self.size = size
        self.scale = scale
    }

    /// Draw stuff on top of the canvas
    ///  - Parameters context: context to draw on
    func drawOnTop(_ draw: (_ context: CGContext) -> Void) {
        context.saveGState()
        draw(context)
        context.restoreGState()
    }

    /// Draw stuff below the canvas
    ///  - Parameters context: context to draw on
    func drawOnBottom(_ draw: (_ context: CGContext) -> Void) {
        // TODO: use mix mode to make it more efficient?
        let snapshot = self.snapshot
        let rect = CGRect(origin: CGPoint.zero, size: size)
        context.clear(rect)
        context.saveGState()
        draw(context)
        context.restoreGState()
        context.draw(snapshot, in: rect)
    }
    
}
