//
//  SignaturePad.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/30/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

final class SignaturePad: UIView {
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

                let coalescedTouchs = event?.coalescedTouches(for: touch) ?? []
                // TODO: also handle estimated touches?
                // XXX:
                for coalescedTouch in coalescedTouchs {
                    context.beginPath()
                    let point = coalescedTouch.preciseLocation(in: self)
                    print("@@@@@ draw \(point)")
                    context.move(to: point)
                    context.addLine(to: point)
                    context.setLineWidth(5)
                    context.strokePath()
                }
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
