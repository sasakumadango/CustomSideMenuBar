//
//  SideMenuViewViewController.swift
//  CustomSideMenuBar
//
//  Created by Yuta S. on 2019/05/25.
//  Copyright © 2019 Yuta S. All rights reserved.
//
//


import UIKit

protocol SideMenuViewControllerDelegate: class {
    func sidemenuaTableView(didSelectRowAt indexPath: IndexPath)
}

class SideMenuViewController: UIViewController {
    
    let menuItem = ["サイドメニュー1"]
    
    weak var delegate: SideMenuViewControllerDelegate?
    
    @IBOutlet weak var sideMenuBaceView: UIView!
    
    @IBOutlet weak var menuTableView: UITableView! {
        didSet {
            self.menuTableView.delegate = self
            self.menuTableView.dataSource = self
        }
    }
    
    @IBOutlet weak var tapViewControllerGesture: UITapGestureRecognizer! {
        didSet {
            self.tapViewControllerGesture.delegate = self
        }
    }
    
    @IBOutlet weak var panViewControllerGesture: UIPanGestureRecognizer!
    
    private var contentMaxWidth: CGFloat {
        return view.bounds.width * 0.8
    }
    
    private var contentRatio: CGFloat {
        get {
            return sideMenuBaceView.frame.maxX / contentMaxWidth
        }
        set {
            let ratio = min(max(newValue, 0), 1)
            self.sideMenuBaceView.frame.origin.x = self.contentMaxWidth * ratio - self.sideMenuBaceView.frame.width
            self.sideMenuBaceView.layer.shadowColor = UIColor.black.cgColor
            self.sideMenuBaceView.layer.shadowRadius = 3.0
            self.sideMenuBaceView.layer.shadowOpacity = 0.8
            
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.3 * ratio)
        }
    }
    
    private var beganLocation: CGPoint = .zero
    private var beganState: Bool = false
    var isShown: Bool {
        return self.parent != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var contentRect = self.view.bounds
        contentRect.size.width = self.contentMaxWidth
        contentRect.origin.x = -contentRect.width
        self.sideMenuBaceView.frame = contentRect
        self.sideMenuBaceView.autoresizingMask = .flexibleHeight
    }
    
    func showContentView(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.contentRatio = 1.0
            }
        } else {
            contentRatio = 1.0
        }
    }
    
    func hideContentView(animated: Bool) {
        let hideAction = {
            self.willMove(toParent: nil)
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentRatio = 0
            }, completion: { _ in
                hideAction()
            })
        } else {
            hideAction()
        }
    }
    
    @IBAction func tappedViewController(_ sender: UITapGestureRecognizer) {
        hideContentView(animated: true)
    }
    
    @IBAction func panViewController(_ sender: UIPanGestureRecognizer) {
        let translation = panViewControllerGesture.translation(in: view)
        if translation.x > 0 && contentRatio == 1.0 {
            return
        }
        
        let location = panViewControllerGesture.location(in: view)
        switch panViewControllerGesture.state {
        case .began:
            self.beganState = self.isShown
            self.beganLocation = location
            if translation.x  >= 0 {
                self.showContentView(animated: true)
            }
        case .changed:
            let distance = self.beganState ? self.beganLocation.x - location.x : location.x - self.beganLocation.x
            if distance >= 0 {
                let ratio = distance / (self.beganState ? self.beganLocation.x : (view.bounds.width - self.beganLocation.x))
                let contentRatio = self.beganState ? 1 - ratio : ratio
                self.contentRatio = contentRatio
            }
            
        case .ended, .cancelled, .failed:
            if contentRatio <= 1.0, contentRatio >= 0 {
                if location.x > beganLocation.x {
                    self.showContentView(animated: true)
                } else {
                    self.hideContentView(animated: true)
                }
            }
            beganLocation = .zero
            beganState = false
            
        case .possible: break
        @unknown default:
            fatalError()
        }
    }
}

extension SideMenuViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self.menuTableView)
        if self.menuTableView.indexPathForRow(at: location) != nil {
            return false
        } else {
            return true
        }
    }
}

extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItem", for: indexPath)
        cell.textLabel?.text = self.menuItem[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.sidemenuaTableView(didSelectRowAt: indexPath)
        self.hideContentView(animated: true)
    }
}
