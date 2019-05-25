//
//  SideMenuItemViewController.swift
//  CustomSideMenuBar
//
//  Created by Yuta S. on 2019/05/25.
//  Copyright © 2019 Yuta S. All rights reserved.
//
//


import UIKit

class SideMenuItemViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tappedCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

