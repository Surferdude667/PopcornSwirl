//
//  customTabBarController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 17/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

// Thanks to Aviel Gross for this solution!
class BaseTabBarController: UITabBarController {

    @IBInspectable var defaultIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }

}
