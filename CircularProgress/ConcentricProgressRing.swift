//
//  ConcentricProgressRing.swift
//
//  Created by Daniel Loewenherz on 6/30/16.
//  Copyright © 2016 Lionheart Software, LLC. All rights reserved.
//

import UIKit

public struct ProgressRing {
    public var width: CGFloat?
    public var color: UIColor?
    public var backgroundColor: UIColor?
    
    public init?(color: UIColor? = nil, backgroundColor: UIColor? = nil, width: CGFloat? = nil) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.width = width
    }
    
    public init(color: UIColor, backgroundColor: UIColor? = nil, width: CGFloat) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.width = width
    }
}

open class ProgressRingLayer: CAShapeLayer {
    var completion: (() -> Void)?
    
    open var progress: CGFloat? {
        get {
            return strokeEnd
        }
        
        set {
            strokeEnd = newValue ?? 0
        }
    }
    
    public var startAngle: CGFloat = CGFloat(-Double.pi / 2) {
        didSet {
            while startAngle >= CGFloat(Double.pi) {
                startAngle -= CGFloat(Double.pi * 2)
            }
            while startAngle < CGFloat(-Double.pi) {
                startAngle += CGFloat(Double.pi * 2)
            }
        }
    }
    
    public init(center: CGPoint, radius: CGFloat, width: CGFloat, color: UIColor) {
        super.init()
        
        let bezier = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(Double.pi * 2 - Double.pi / 2), clockwise: true)
        delegate = self as? CALayerDelegate
        path = bezier.cgPath
        fillColor = UIColor.clear.cgColor
        strokeColor = color.cgColor
        lineWidth = width
        lineCap = CAShapeLayerLineCap.round
        strokeStart = 0
        strokeEnd = 0
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    open func setProgress(_ startProgress: CGFloat,progress: CGFloat, duration: CGFloat, completion: (() -> Void)? = nil) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = strokeEnd
        animation.toValue = progress
        animation.duration = CFTimeInterval(duration)
        animation.delegate = self as? CAAnimationDelegate
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        strokeEnd = progress
        add(animation, forKey: "strokeEnd")
        
        /// Custom text layer for description
        var textLayer: CATextLayer!
        
        if self.sublayers != nil {
            textLayer = self.sublayers!.first as? CATextLayer
        } else {
            textLayer = CATextLayer()
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.isWrapped = true
            textLayer.alignmentMode = .center
            addSublayer(textLayer)
        }
        
        textLayer.foregroundColor = UIColor.red.cgColor
        textLayer.backgroundColor = UIColor.yellow.cgColor
        textLayer.font = UIFont.systemFont(ofSize: 12.0)
        textLayer.fontSize = 12.0
        textLayer.string = "\(progress)"
        
        let size: CGSize = CGSize.init(width: 20.0, height: 12.0)
        textLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        
        var startAngle = -90.0 + ( startProgress * 360)
        var value = progress - startProgress
        var endAngle = startAngle + ( value * 360 ) - 4
        var midAngel = startAngle + (endAngle - startAngle)/2
        print("====== \(startAngle) \(endAngle) \(midAngel)")
        
        let  x = 100.0  + (82.0) * CGFloat(cos(CGFloat(midAngel).deg2rad()))
        let  y = 100.0  + (82.0) * CGFloat(sin(CGFloat(midAngel).deg2rad()))
        
        textLayer.position = CGPoint.init(x: x, y: y)
        print("\(x) \(y)")

    }
    
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            completion?()
        }
    }
}

public final class CircleLayer: ProgressRingLayer {
    override init(center: CGPoint, radius: CGFloat, width: CGFloat, color: UIColor) {
        super.init(center: center, radius: radius, width: width, color: color)
        progress = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum ConcentricProgressRingViewError: Error {
    case invalidParameters
}

public final class ConcentricProgressRingView: UIView, Sequence {
    public var arcs: [ProgressRingLayer] = []
    var circles: [CircleLayer] = []
    
    @available(*, unavailable, message: "Progress rings without a color, width, or progress set (such as those provided) can't be used with this initializer. Please use the other initializer that accepts default values.")
    public init?(center: CGPoint, radius: CGFloat, margin: CGFloat, rings: [ProgressRing?]) {
        return nil
    }
    
    public convenience init(center: CGPoint, radius: CGFloat, margin: CGFloat, rings theRings: [ProgressRing?], defaultColor: UIColor? = UIColor.white, defaultBackgroundColor: UIColor = UIColor.clear, defaultWidth: CGFloat?) throws {
        var rings: [ProgressRing] = []
        
        for ring in theRings {
            guard var ring = ring else {
                continue
            }
            
            guard let color = ring.color ?? defaultColor,
                  let width = ring.width ?? defaultWidth else {
                      throw ConcentricProgressRingViewError.invalidParameters
                  }
            
            let backgroundColor = ring.backgroundColor ?? defaultBackgroundColor
            
            ring.color = color
            ring.backgroundColor = backgroundColor
            ring.width = width
            rings.append(ring)
        }
        
        self.init(center: center, radius: radius, margin: margin, rings: rings)
    }
    
    public init(center: CGPoint, radius: CGFloat, margin: CGFloat, rings: [ProgressRing]) {
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        let theCenter = CGPoint(x: radius, y: radius)
        
        super.init(frame: frame)
        
        var offset: CGFloat = 0
        for ring in rings {
            let color = ring.color!
            let width = ring.width!
            
            //let radius = radius - (width / 2) - offset
            offset = offset + margin + width
            
            if let backgroundColor = ring.backgroundColor {
                let circle = CircleLayer(center: theCenter, radius: radius, width: width, color: backgroundColor)
                circles.append(circle)
                layer.addSublayer(circle)
            }
            
            let arc = ProgressRingLayer(center: theCenter, radius: radius, width: width, color: color)
            arcs.append(arc)
            layer.addSublayer(arc)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public subscript(index: Int) -> ProgressRingLayer {
        return arcs[index]
    }
    
    public func makeIterator() -> IndexingIterator<[ProgressRingLayer]> {
        return arcs.makeIterator()
    }
}
