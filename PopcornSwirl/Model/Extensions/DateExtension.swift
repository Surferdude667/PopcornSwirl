//
//  DateExtension.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 22/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

extension Date {
    func toString(format: String = "dd/MM/yy") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
