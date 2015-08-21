//
//  ButtonIconRight.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 8/19/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class ButtonIconRight: UIButton {
    
    override func imageRectForContentRect(contentRect:CGRect) -> CGRect {
        var imageFrame = super.imageRectForContentRect(contentRect)
        imageFrame.origin.x = CGRectGetMaxX(super.titleRectForContentRect(contentRect)) - CGRectGetWidth(imageFrame)
        
        return imageFrame
    }
    
    override func titleRectForContentRect(contentRect:CGRect) -> CGRect {
        var titleFrame = super.titleRectForContentRect(contentRect)
        if (self.currentImage != nil) {
            titleFrame.origin.x = CGRectGetMinX(super.imageRectForContentRect(contentRect)) - 15
        }
        return titleFrame
    }
}