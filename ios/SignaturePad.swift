//
//  SignaturePad.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/30/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

class Line {
    var lastPoint: CGPoint

    init(startPoint: CGPoint) {
        lastPoint = startPoint
    }
}

final class SignaturePad: UIView {
    fileprivate var lines: [UITouch: Line] = [:]
    fileprivate var frozenCanvas: FrozenCanvas!

    var frozenImage: CGImage {
        return frozenCanvas.snapshot
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        frozenCanvas = FrozenCanvas(size: frame.size, scale: UIScreen.main.scale)
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        frozenCanvas = FrozenCanvas(size: bounds.size, scale: UIScreen.main.scale)
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
    }

    deinit {
        removeObserver(self, forKeyPath: "frame")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "frame") {
            self.frozenCanvas = FrozenCanvas(size: frame.size, scale: UIScreen.main.scale)
        }
    }
}

// MARK: Handle drawing
extension SignaturePad {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.draw(frozenImage, in: bounds)
    }
}

// MARK: Handle touches
extension SignaturePad {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // do not process touches from subviews
            guard touch.view === self else {
                continue
            }
            let line = Line(startPoint: touch.preciseLocation(in: self))
            lines[touch] = line

            let coalescedTouchs = event?.coalescedTouches(for: touch) ?? []
            print("@@@@@@ \(touch) \(coalescedTouchs)")
            // TODO: draw stuff?
            /*
            if let line = lines[touch] {
                if let lastTouch = coalescedTouchs.last {
                    line.lastPoint = lastTouch.location(in: self)
                    print("!!!!! first last point for \(touch)")
                }
            }*/
        }
        // TODO:
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.frozenCanvas.drawOnTop { (context) in
            context.saveGState()
            context.setLineCap(.round)
            context.setStrokeColor(UIColor.black.cgColor)
            for touch in touches {
                // do not process touches from subviews
                guard touch.view === self else {
                    continue
                }
                guard let line = lines[touch] else {
                    continue
                }
                let coalescedTouchs = event?.coalescedTouches(for: touch) ?? []
                let points = coalescedTouchs.map { [unowned self] coalescedTouch in
                    return coalescedTouch.preciseLocation(in: self)
                }
                context.beginPath()
                context.move(to: line.lastPoint)
                for point in points {
                    context.addLine(to: point)
                    context.setLineWidth(5)
                }
                context.strokePath()
                line.lastPoint = points.last!
            }
            // XXX:
            context.restoreGState()
        }
        // TODO: find a smarter way to determine region for redrew
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO:
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO:
    }
}
