//
//  CarouselViewController.swift
//  AnimateMe
//
//  Created by Alexandra Bashkirova on 26.11.2021.
//

import AnKit
import UIKit
import BRQBottomSheet

class CarouselViewController: UIViewController {
    
    @IBOutlet weak var launchView: UIView!
    @IBOutlet weak var firstWave: CLWaterWaveView!
    @IBOutlet weak var alphaWave: CLWaterWaveView!
    @IBOutlet weak var secondWave: CLWaterWaveView!
    
    private let remoteImageCardHeight: CGFloat = UIScreen.main.bounds.height * 0.4
    private let remoteImageCardWidth: CGFloat = UIScreen.main.bounds.width * 0.6
    
    var animationDuration: TimeInterval = 0.85
    var delay: TimeInterval = 0.05
    var isLoading = false {
        didSet {
            isLoading ? startLoading() : endLoading()
        }
    }
    let loadingLayer = CALayer()
    
    private lazy var collectionView = CollectionView()
    var shouldAnimateDifferences: Bool {
        if !UIView.areAnimationsEnabled {
            return false
        }
        
        return true
    }
    
    var items: [DataItem] = []
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        fillCollectionView()
        firstWave.startAnimation()
        secondWave.startAnimation()
        alphaWave.startAnimation()
        
        
        loadingLayer.frame = CGRect(x: 0, y: 0, width: 124, height: 74)
        loadingLayer.contents = UIImage(named: "podlodka")?.cgImage
        loadingLayer.contentsGravity = .resizeAspect
        loadingLayer.anchorPoint = CGPoint(x: 0.5, y: 0.9)
        view.layer.addSublayer(loadingLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loadingLayer.position = CGPoint(x: view.center.x, y: 30)
    }
    
    func setupUI() {
        [collectionView].addAsSubviewForConstraintsUse(to: view)
        
        NSLayoutConstraint.activate(collectionView.makeConstraints(to: view.safeAreaLayoutGuide))
    }
    
    func fillCollectionView() {
        isLoading = true
        Services.dataService.get { items in
            self.items = items
            do {
                let infoCardItems: [InfoCardItem] = items.compactMap { try? self.makeRemoteImageItem(data: $0) }
                let section = try ScaleCarouselSection(
                    items: infoCardItems.dropLast(items.count/2),
                    itemWidthDimension: .absolute(self.remoteImageCardWidth),
                    itemHeightDimension: .absolute(self.remoteImageCardHeight),
                    contentInsets: .default()
                )
                let section2 = try ScaleCarouselSection(
                    items: Array(infoCardItems.dropFirst(items.count/2)),
                    itemWidthDimension: .absolute(self.remoteImageCardWidth),
                    itemHeightDimension: .absolute(self.remoteImageCardHeight),
                    contentInsets: .default()
                )
                self.isLoading = false
                try self.collectionView.set(
                    sections: [section, section2],
                    animatingDifferences: self.shouldAnimateDifferences
                )
                
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        
    }
    
    func makeRemoteImageItem(
        data: DataItem
    ) throws -> InfoCardItem {
        let item = try InfoCardItem(
            content: InfoCardItem.Content(
                imageContent: UIImage(named: data.image)!,
                text: data.title,
                footnoteText: "Время: \(data.time)"
            ),
            imageViewContentMode: .scaleToFill
        )
        item.onTap = { [weak self] in
            self?.onTapCell(data: data)
        }
        return item
    }
    
    func onTapCell(data: DataItem) {
        print(data)
        let vc = AuthorCardViewController()
        vc.data = data
        let bottomSheet = BRQBottomSheetViewController(viewModel: BRQBottomSheetViewModel(), childViewController: vc)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    
    }
    
}


extension CarouselViewController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard isLoading else {
            return
        }
        startLoading()
    }
    
}


extension CarouselViewController {
    private func randomPoint() -> CGPoint {
        let x = CGFloat.random(in: 0...view.frame.maxX)
        let y = CGFloat.random(in: 0...view.frame.maxY)
        return CGPoint(x: x, y: y)
    }
    
    func startLoading() {
        loadingLayer.opacity = 1.0
        let displayLayer = loadingLayer.presentation() ?? loadingLayer
        let endPosition = randomPoint()
        let points = [
            displayLayer.position,
            randomPoint(),
            randomPoint(),
            endPosition
        ]
        
        let path: UIBezierPath = {
            let path = UIBezierPath()

            guard let firstPoint = points.first else {
                return path
            }

            path.move(to: firstPoint)
            points.suffix(from: 1).forEach {
                path.addLine(to: $0)
            }

            return path
        }()
        
        let moveAnimation = CAKeyframeAnimation(keyPath: "position")
        
        moveAnimation.path = path.cgPath
        moveAnimation.rotationMode = .rotateAuto
        
        moveAnimation.duration = 1

        moveAnimation.delegate = self
        
        moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        moveAnimation.setValue("move", forKey: "id")
        
        loadingLayer.position = endPosition
        loadingLayer.add(moveAnimation, forKey: "move")
    }
    
    func endLoading() {
        loadingLayer.removeAllAnimations()
        loadingLayer.opacity = 0.0
    }
}

