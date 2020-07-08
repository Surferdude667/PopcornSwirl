//
//  RoundButton.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 08/07/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var borderColor: UIColor? = .lightGray
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = borderColor?.cgColor
        
    }
}
