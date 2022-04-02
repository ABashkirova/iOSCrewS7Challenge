//
//  LaunchViewController.swift
//  AnimateMe
//
//  Created by Alexandra Bashkirova on 25.11.2021.
//

import UIKit

extension LoginViewController {
    
    func setupLaunchViews() {
        
        firstWave.startAnimation()
        secondWave.startAnimation()
        alphaWave.startAnimation()
        alphaWave.delegate = self
        
        pulsebutton = PulsatingButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        pulsebutton.center = alphaWave.center
        view.addSubview(pulsebutton)
        pulsebutton.alpha = 0
        
        podlodkaImageView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
    }
    
    func didAppearLaunch() {
        UIView.animate(withDuration: 1, delay: 0, options: .transitionCrossDissolve) {
            self.pulsebutton.alpha = 1
            self.podlodkaImageView.transform = .identity
        } completion: { _ in
            self.pulsebutton.pulse()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(upWaves))
        pulsebutton.addGestureRecognizer(tap)
        podlodkaImageView.layer.add(rotation(degree: 8), forKey: nil)
      
    }
    
    fileprivate func hidePulseButton() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve) {
            self.pulsebutton.alpha = 0
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(upWaves))
        view.addGestureRecognizer(tap)
    }
    
    @objc func upWaves(_ sender: Any) {
        guard countStartAppTaps != maxCountStartAppTaps else {
            return
        }
        countStartAppTaps += 1
        if countStartAppTaps == 2 {
            hidePulseButton()
        }
        
        guard countStartAppTaps < maxCountStartAppTaps else {
            showLogin()
            return
        }
        
        firstWaveHeightConstraint = incrementConstraintMultiplier(firstWaveHeightConstraint, step: countStartAppTaps)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
        secondWaveHeightConstraint = incrementConstraintMultiplier(secondWaveHeightConstraint, step: countStartAppTaps)
        UIView.animate(withDuration: 0.25, delay: 0.05, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
        alphaWaveHeightConstraint = incrementConstraintMultiplier(alphaWaveHeightConstraint, step: countStartAppTaps)
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func incrementConstraintMultiplier(_ constraint: NSLayoutConstraint, step: CGFloat) -> NSLayoutConstraint {
        constraint.setMultiplier(
            multiplier: constraint.multiplier + CGFloat((1.2 - constraint.multiplier) / (maxCountStartAppTaps - step))
        )
    }
    
    private func rotation(degree: CGFloat) -> CAAnimation {
        let angle: CGFloat = degree * .pi / 180
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = -angle
        rotate.toValue = angle
        rotate.duration = 5
        rotate.repeatCount = .infinity
        rotate.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotate.fillMode = .backwards
        rotate.autoreverses = true
        return rotate
    }
}

class PulsatingButton: UIButton {
    let pulseLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeColor = UIColor.clear.cgColor
        shape.lineWidth = 10
        shape.fillColor = UIColor.white.withAlphaComponent(0.3).cgColor
        shape.lineCap = .round
        return shape
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShapes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShapes()
    }
    
    fileprivate func setupShapes() {
        setNeedsLayout()
        layoutIfNeeded()
        
        let backgroundLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: self.center, radius: bounds.size.height/2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        pulseLayer.frame = bounds
        pulseLayer.path = circularPath.cgPath
        pulseLayer.position = self.center
        self.layer.addSublayer(pulseLayer)
        
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.lineWidth = 10
        backgroundLayer.fillColor = UIColor.white.withAlphaComponent(0.4).cgColor
        backgroundLayer.lineCap = .round
        self.layer.addSublayer(backgroundLayer)
    }
    
    func pulse() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.2
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        pulseLayer.add(animation, forKey: "pulsing")
    }
}

extension LoginViewController: CLWaterWaveModelDelegate {
    func waterWaveModel(_ waterWaveModel: CLWaterWaveModel, didUpdate wavePath: CLWaterWavePath) {
        let points = wavePath.cgPath.getPathElementsPoints()
        let ceterX = UIScreen.main.bounds.width / 2
        let depthHeight = points.first(where: { abs($0.x - ceterX) <= 1 })?.y
        podlodkaBottomConstraint.constant =
        alphaWave.bounds.height
        - (podlodkaImageView.bounds.height/2)
        - 1.25 * (depthHeight ?? podlodkaBottomConstraint.constant)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension CGPath {
    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        //print(MemoryLayout.size(ofValue: body))
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    func getPathElementsPoints() -> [CGPoint] {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            default: break
            }
        }
        return arrayPoints
    }
    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        return (arrayPoints,arrayTypes)
    }
}
