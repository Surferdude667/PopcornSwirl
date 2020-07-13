//
//  BlurLoader.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 10/07/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//  Credits to Maor: https://stackoverflow.com/users/5561910/maor

import UIKit

extension UIView {
    func showBlurLoader() {
        let blurLoader = BlurLoader(frame: frame)
        self.addSubview(blurLoader)
    }

    func removeBluerLoader() {
        if let blurLoader = subviews.first(where: { $0 is BlurLoader }) {
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                blurLoader.alpha = 0.0
            }){ (finished) in
                blurLoader.removeFromSuperview()
            }
            
            
        }
    }
}


class BlurLoader: UIView {

    var blurEffectView: UIVisualEffectView?

    override init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView = blurEffectView
        super.init(frame: frame)
        addSubview(blurEffectView)
        addLoader()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLoader() {
        guard let blurEffectView = blurEffectView else { return }
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.color = .lightGray
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        activityIndicator.startAnimating()
        blurEffectView.alpha = 0.0
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            blurEffectView.alpha = 1.0
        })
    }
}
