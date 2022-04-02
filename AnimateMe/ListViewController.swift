//
//  ListViewController.swift
//  AnimateMe
//
//  Created by katleta3000 on 21.11.2021.
//

import UIKit

final class ListViewCell: UITableViewCell {
    @IBOutlet var avatar: UIImageView! {
        didSet {
            avatar.layer.cornerRadius = 30
        }
    }
    @IBOutlet var author: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var time: UILabel!
}

final class ListViewController: UITableViewController {
    var animationDuration: TimeInterval = 0.85
    var delay: TimeInterval = 0.05
    
    var myView: UITableView { self.view as! UITableView }
    private var items = [DataItem]()
    
    var isLoading = false {
        didSet {
            isLoading ? startLoading() : endLoading()
        }
    }
    let loadingLayer = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        loadingLayer.contents = UIImage(named: "podlodka")?.cgImage
        loadingLayer.contentsGravity = .resizeAspect
        loadingLayer.anchorPoint = CGPoint(x: 0.5, y: 0.7)
        
        tableView.backgroundView = UIView(frame: tableView.frame)
        tableView.backgroundView?.layer.addSublayer(loadingLayer)
        
        self.tableView.separatorStyle = .none
        isLoading = true
        Services.dataService.get { items in
            self.items = items
            self.isLoading = false
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loadingLayer.position = tableView.backgroundView?.center ?? view.center
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCell", for: indexPath) as! ListViewCell
        let item = items[indexPath.row]
        cell.author.text = item.author
        cell.title.text = item.title
        cell.time.text = item.time
        cell.avatar.image = UIImage(named: item.image)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let animation = TableViewAnimator.makeMoveUpWithFadeAnimation(rowHeight: cell.frame.height, duration: animationDuration, delayFactor: delay)
        let animator = TableViewAnimator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }
    
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

extension ListViewController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard isLoading else {
            return
        }
        startLoading()
    }
    
}

typealias TableCellAnimation = (UITableViewCell, IndexPath, UITableView) -> Void

final class TableViewAnimator {
    private let animation: TableCellAnimation
    
    init(animation: @escaping TableCellAnimation) {
        self.animation = animation
    }
    
    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        animation(cell, indexPath, tableView)
    }
    
    static func makeMoveUpWithFadeAnimation(rowHeight: CGFloat, duration: TimeInterval, delayFactor: TimeInterval) -> TableCellAnimation {
           return { cell, indexPath, _ in
               cell.transform = CGAffineTransform(translationX: 0, y: rowHeight * 1.4)
               cell.alpha = 0
               UIView.animate(
                   withDuration: duration,
                   delay: delayFactor * Double(indexPath.row),
                   options: [.curveEaseInOut],
                   animations: {
                       cell.transform = CGAffineTransform(translationX: 0, y: 0)
                       cell.alpha = 1
               })
           }
       }
}
