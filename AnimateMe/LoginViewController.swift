//
//  ViewController.swift
//  AnimateMe
//
//  Created by katleta3000 on 21.11.2021.
//

import UIKit
extension UIColor {
    static let purple = UIColor(named: "Purple")!
}

final class LoginViewController: UIViewController {
    // Launch
    @IBOutlet weak var launchView: UIView!

    @IBOutlet weak var firstWave: CLWaterWaveView!
    @IBOutlet weak var alphaWave: CLWaterWaveView!
    @IBOutlet weak var secondWave: CLWaterWaveView!

    @IBOutlet weak var podlodkaImageView: UIImageView!
    var pulsebutton: PulsatingButton!
    
    var countStartAppTaps: CGFloat = 0
    let maxCountStartAppTaps: CGFloat = 20
    
    @IBOutlet weak var firstWaveHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondWaveHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alphaWaveHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var podlodkaBottomConstraint: NSLayoutConstraint!
    
    // Login
    let colorPurple = UIColor(named: "Purple")!
    
    @IBOutlet var username: UITextField! {
        didSet {
            username.layer.borderColor = colorPurple.cgColor
            username.layer.borderWidth = 1
        }
    }
    
    @IBOutlet var password: UITextField! {
        didSet {
            password.layer.borderColor = colorPurple.cgColor
            password.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var loadingContainer: UIView!
    var loadingView: DotsAnimationView = DotsAnimationView(dotSize: .init(width: 10, height: 10), dotColor: .white, animationTime: 0.9)
    @IBOutlet var login: UIButton! {
        didSet {
            login.backgroundColor = UIColor(named: "Purple")
            login.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    private let loginService = Services.loginService
    
    @IBAction func clickedLogin() {
        startLoading()
        loginService.login(login: username.text ?? "", password: password.text ?? "") { [weak self] success in
            
            self?.endLoading()
            if success {
                self?.performSegue(withIdentifier: "CollectionView", sender: nil)
            } else {
                self?.showInvalidLogin()
                
            }
        }
    }
    
    fileprivate func setupLoadingView() {
        loadingContainer.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.topAnchor.constraint(equalTo: loadingContainer.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: loadingContainer.bottomAnchor).isActive = true
        loadingView.leftAnchor.constraint(equalTo: loadingContainer.leftAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: loadingContainer.rightAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorLabel.alpha = 0
        self.loadingView.alpha = 0
        showHideLogin(false)
        setupLaunchViews()
        setupLoadingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        didAppearLaunch()
    }
    
    func showLogin() {
        UIView.animate(withDuration: 2, delay: 0, options: .transitionCrossDissolve) {
            self.showHideLogin(true)
        }
    }
    
    func startLoading() {
        login.isUserInteractionEnabled = false
        login.hide()
        loadingView.show()
        loadingView.startAnimation()
    }
    
    func endLoading() {
        loadingView.stopAnimation()
        loadingView.hide()
        login.isUserInteractionEnabled = true
        login.show()
    }
    
    private func showHideLogin(_ visible: Bool) {
        self.login.alpha = visible ? 1 : 0
        self.username.alpha = visible ? 1 : 0
        self.password.alpha = visible ? 1 : 0
        self.logo.alpha = visible ? 1 : 0
    }
    
    fileprivate func shakeLogin(_ duration: Double) {
        [self.login, self.username, self.password].forEach { $0.shake(duration) }
    }
    
    fileprivate func fillStateFieldColors(_ duration: Double, color: UIColor) {
        [self.username, self.password].forEach { $0?.animateBorderColor(toColor: color, duration: duration * 2) }
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut]) {
            self.username.textColor = color
            self.password.textColor = color
        }
    }
    
    private func showInvalidLogin() {
        let duration: Double = 1
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        login.setTitle("Ой-ёй!", for: .normal)
        shakeLogin(duration)
        fillStateFieldColors(duration, color: .red)
        animateColor(for: login, color: .red) {
            self.animateColor(for: self.login, color: .purple)
            self.fillStateFieldColors(duration, color: .purple)
            self.hideError()
            self.login.setTitle("Еще раз! Погружаемся!", for: .normal)
        }
        showError()
        CATransaction.commit()
    }
    
    private func showError() {
        errorLabel.show()
    }
    
    private func hideError() {
        errorLabel.hide()
    }
    
    private func animateColor(for view: UIView, color: UIColor, duration: Double = 1, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: 0, options: .curveEaseIn
        ) {
            view.backgroundColor = color
        } completion: { _ in
            completion?()
        }
    }
    
}
// MARK: Animations

extension UIView {
    func show() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn, .transitionCrossDissolve]) {
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn, .transitionCrossDissolve]) {
            self.alpha = 0
        }
    }
    
    func wiggle(_ duration: Double) {
        let wiggle = wiggle(layer: layer, degreesRotation: 3)
        wiggle.duration = duration
        layer.add(wiggle, forKey: "wiggle")
    }
    
    func shake(_ duration: Double) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.0, 2.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    func animateBorderColor(toColor: UIColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = toColor.cgColor
        animation.duration = duration
        layer.add(animation, forKey: "borderColor")
        layer.borderColor = toColor.cgColor
    }
    
    private func wiggle(layer: CALayer, degreesRotation: CGFloat) -> CAAnimation {
        let wiggleAnimation = CAAnimationGroup()
        wiggleAnimation.autoreverses = true
        wiggleAnimation.fillMode = .both
        wiggleAnimation.animations = [shake(layer: layer), rotation(degree: degreesRotation)]
        wiggleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return wiggleAnimation
    }
    
    private func rotation(degree: CGFloat) -> CAAnimation {
        let angle: CGFloat = degree * .pi / 180
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = -angle
        rotate.toValue = angle
        return rotate
    }
    
    private func shake(layer: CALayer) -> CAAnimation {
        let shake = CAKeyframeAnimation(keyPath: "position")
        shake.values = [
            layer.position,
            CGPoint(x: layer.position.x, y: layer.position.y + 5),
            CGPoint(x: layer.position.x + 5, y: layer.position.y),
            CGPoint(x: layer.position.x, y: layer.position.y - 5),
            CGPoint(x: layer.position.x - 5, y: layer.position.y),
            CGPoint(x: layer.position.x, y: layer.position.y)
        ]
        shake.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        return shake
    }
    
}
