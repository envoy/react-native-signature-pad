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
    fileprivate var lines: [UITouch: Line] = [:]
    fileprivate var painter: SignaturePainter!
    fileprivate var dirtyRect: CGRect?

    var debug: Bool = false {
        didSet {
            if debug {
                debugPainter = DebugSignaturePainter()
                debugFrozenCanvas = FrozenCanvas(size: frame.size, scale: UIScreen.main.scale)
            }
        }
    }
    fileprivate var debugFrozenCanvas: FrozenCanvas!
    fileprivate var debugLines: [UITouch: Line] = [:]
    fileprivate var debugPainter: SignaturePainter?

    var frozenImage: CGImage {
        return frozenCanvas.snapshot
    }

    var frozenDebugImage: CGImage? {
        return debugFrozenCanvas.snapshot
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initPad()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initPad()
    }

    deinit {
        removeObserver(self, forKeyPath: "frame")
    }

    func initPad() {
        painter = SmoothSignaturePainter()
        painter.updateDirtyRect = onUpdateDirtyRect
        frozenCanvas = FrozenCanvas(size: frame.size, scale: UIScreen.main.scale)
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.init(rawValue: 0), context: nil)
        if debug {
            debugPainter = DebugSignaturePainter()
            debugFrozenCanvas = FrozenCanvas(size: frame.size, scale: UIScreen.main.scale)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "frame") {
            // TODO: copy image from original canvas
            frozenCanvas = FrozenCanvas(size: frame.size, scale: UIScreen.main.scale)
            if debug {
                debugFrozenCanvas = FrozenCanvas(size: frame.size, scale: UIScreen.main.scale)
            }
        }
    }
}

// MARK: Handle drawing
extension SignaturePad {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        if !rect.contains(bounds) {
            // XXX:
            context.setFillColor(UIColor(red: 0, green: 0, blue: 1, alpha: 0.5).cgColor)
            context.addRect(rect)
            context.fillPath()
        }

        context.draw(frozenImage, in: bounds)
        if let canvas = debugFrozenCanvas {
            context.draw(canvas.snapshot, in: bounds)
        }
    }

    func onUpdateDirtyRect(rect: CGRect) {
        if dirtyRect == nil {
            dirtyRect = rect
            return
        }
        dirtyRect = dirtyRect?.union(rect)
    }

    func updateNeedsDisplay() {
        if let rect = dirtyRect {
            setNeedsDisplay(rect)
            dirtyRect = nil
        }
    }
}

// MARK: Handle touches
extension SignaturePad {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        frozenCanvas.drawOnTop { (context) in
            for touch in touches {
                // do not process touches from subviews
                guard touch.view === self else {
                    continue
                }
                let point = pointForTouch(touch)

                let line = painter.addLine()
                lines[touch] = line
                line.start(context: context, point: point)

                if let painter = debugPainter {
                    let debugLine = painter.addLine()
                    debugLines[touch] = debugLine
                    debugLine.start(context: context, point: point)
                }

            }
        }
        updateNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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
                let point = pointForTouch(coalescedTouch)
                frozenCanvas.drawOnTop { (context) in
                    line.add(context: context, point: point)
                }
                debugFrozenCanvas?.drawOnTop({ context in
                    debugLines[touch]?.add(context: context, point: point)
                })
            }
        }
        updateNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
                let point = pointForTouch(coalescedTouch)
                frozenCanvas.drawOnTop { (context) in
                    line.end(context: context, point: point)
                }
                debugFrozenCanvas?.drawOnTop({ context in
                    debugLines[touch]?.end(context: context, point: point)
                })
            }
            lines.removeValue(forKey: touch)
            debugLines.removeValue(forKey: touch)
        }
        updateNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       touchesEnded(touches, with: event)
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
