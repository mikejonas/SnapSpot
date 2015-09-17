//
//  UIView+Extension.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 9/15/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func fadeIn(duration: NSTimeInterval = 0.1, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 0.1, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
}