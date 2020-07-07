//
//  ColorManager.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 06/07/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class ColorManager {
    
    func provideGenreColor(_ genre: Genre) -> UIColor {
        switch genre {
        case .action:
            return #colorLiteral(red: 0.968627451, green: 0.7764705882, blue: 0.2039215686, alpha: 1)
        case .comedy:
            return #colorLiteral(red: 0.7137254902, green: 0.3294117647, blue: 1, alpha: 1)
        case .drama:
            return #colorLiteral(red: 0.2509803922, green: 1, blue: 0.7529411765, alpha: 1)
        case .family:
            return #colorLiteral(red: 0.1294117647, green: 0.7294117647, blue: 0.2156862745, alpha: 1)
        case .horror:
            return #colorLiteral(red: 1, green: 0.06274509804, blue: 0.06274509804, alpha: 1)
        case .romance:
            return #colorLiteral(red: 1, green: 0.4039215686, blue: 0.6156862745, alpha: 1)
        case .thriller:
            return #colorLiteral(red: 1, green: 0.4470588235, blue: 0, alpha: 1)
        }
    }
    
}
