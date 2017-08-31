//
//  SignaturePad.swift
//  SignaturePad
//
//  Created by Fang-Pen Lin on 8/30/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

final class SignaturePad: UIView {
    fileprivate var lines: [UITouch: Line] = [:]
    fileprivate var frozenCanvas: FrozenCanvas!
    fileprivate var painter: SignaturePainter

    var frozenImage: CGImage {
        return frozenCanvas.snapshot
    }

    override init(frame: CGRect) {
        painter = SimpleSignaturePainter()
        super.init(frame: frame)
        frozenCanvas = FrozenCanvas(size: frame.size, scale: UIScreen.main.scale)
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        painter = SimpleSignaturePainter()
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
            let line = painter.addLine()
            lines[touch] = line
            frozenCanvas.drawOnTop { (context) in
                line.start(
                    context: context,
                    point: pointForTouch(touch)
                )
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.frozenCanvas.drawOnTop { (context) in
            for touch in touches {
                // do not process touches from subviews
                guard touch.view === self else {
                    continue
                }
                guard let line = lines[touch] else {
                    continue
                }
                let coalescedTouchs = event?.coalescedTouches(for: touch) ?? []
                for coalescedTouch in coalescedTouchs {
                    line.add(
                        context: context,
                        // TODO: the date
                        point: pointForTouch(coalescedTouch)
                    )
                }
            }
        }
        // TODO: find a smarter way to determine region for redrew
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.frozenCanvas.drawOnTop { (context) in
            for touch in touches {
                // do not process touches from subviews
                guard touch.view === self else {
                    continue
                }
                guard let line = lines[touch] else {
                    continue
                }
                let coalescedTouchs = event?.coalescedTouches(for: touch) ?? []
                for coalescedTouch in coalescedTouchs {
                    line.end(
                        context: context,
                        point: pointForTouch(coalescedTouch)
                    )
                }
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO:
    }

    private func pointForTouch(_ touch: UITouch) -> Point {
        return Point(
            position: touch.location(in: self),
            timestamp: touch.timestamp,
            stylus: touch.type == .stylus,
            force: touch.force,
            altitudeAngle: touch.altitudeAngle,
            azimuthAngle: touch.azimuthAngle(in: self)
        )
    }
}
