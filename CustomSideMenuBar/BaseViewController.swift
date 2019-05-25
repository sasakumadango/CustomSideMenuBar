//
//  BaseViewController.swift
//  CustomSideMenuBar
//
//  Created by Yuta S. on 2019/05/25.
//  Copyright © 2019 Yuta S. All rights reserved.
//
//


import UIKit

/// ベース画面
class BaseViewController: UIViewController {
    
    @IBOutlet weak var baseTabBar: UITabBar! {
        didSet {
            self.baseTabBar.selectedItem = self.baseTabBar.items![0]
        }
    }
    
    lazy var pageViewController: BasePageViewController = {
        return self.children[0] as! BasePageViewController
    }()
    
    lazy var sideMenuViewController = { [unowned self] () -> SideMenuViewController in
        let viewController = SideManuBuilder().build() as! SideMenuViewController
        viewController.delegate = self
        return viewController
        }()
    
    private var isShownSidemenu: Bool {
        return sideMenuViewController.parent == self
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tappedSideMenuButton(_ sender: UIBarButtonItem) {
        self.showSideMenu()
    }
    
    private func showSideMenu() {
        if isShownSidemenu { return }
        
        self.addChild(sideMenuViewController)
        self.sideMenuViewController.view.autoresizingMask = .flexibleHeight
        self.sideMenuViewController.view.frame = self.view.bounds
        self.view.insertSubview(sideMenuViewController.view, aboveSubview: self.view)
        sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        sideMenuViewController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        sideMenuViewController.view.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        self.sideMenuViewController.didMove(toParent: self)
        self.sideMenuViewController.showContentView(animated: true)
    }
    
    private func showSetting() {
        let settingViewController = SettingBuilder().build()
        settingViewController.modalPresentationStyle = .overCurrentContext
        settingViewController.modalTransitionStyle = .crossDissolve
        present(settingViewController, animated: true)
    }
}

extension BaseViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.pageViewController.setCurentViewController(index: item.tag)
    }
}

extension BaseViewController: SideMenuViewControllerDelegate {
    func sidemenuaTableView(didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            self.showSetting()
        default:
            return
        }
    }
}

private struct SideManuBuilder {
    func build() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainSideMenuViewController = storyboard.instantiateViewController(withIdentifier: "SideMenu")
        return mainSideMenuViewController
    }
}

private struct SettingBuilder {
    func build() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingViewController = storyboard.instantiateViewController(withIdentifier: "SideMenuItemViewController")
        return settingViewController
    }
}
