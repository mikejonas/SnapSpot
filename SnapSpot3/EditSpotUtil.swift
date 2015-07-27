//
//  editSpotUtil.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/25/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import Foundation

class EditSpotUtil: NSObject {

    var photoThumbnail0:UIImageView!
    var photoThumbnail1:UIImageView!
    var photoThumbnail2:UIImageView!
    
    var imageArray: [UIImage] = []
    var imageViewArray: [UIImageView]!
    var deleteImageButton = UIButton()
    
    func generateImagesInView(imageContainerView:UIView) {
        photoThumbnail0 = UIImageView(frame:CGRectMake(0, 0, 200, 200))
        photoThumbnail0.backgroundColor = UIColor.purpleColor()
        imageContainerView.addSubview(photoThumbnail0)
        
        photoThumbnail1 = UIImageView(frame:CGRectMake(205, 0, 100, 100))
        photoThumbnail1.backgroundColor = UIColor.purpleColor()
        imageContainerView.addSubview(photoThumbnail1)
        
        photoThumbnail2 = UIImageView(frame:CGRectMake(205, 105, 100, 100))
        photoThumbnail2.backgroundColor = UIColor.purpleColor()
        imageContainerView.addSubview(photoThumbnail2)
        
        imageViewArray  = [photoThumbnail0, photoThumbnail1, photoThumbnail2]
    }
    
    func addImage(image:UIImage) {
        imageArray.append(image)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.reloadImages()
        })
    }
    func removeImage(imageIndex:Int) {
        imageArray.removeAtIndex(imageIndex)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.reloadImages()
        })
    }
    
    func reloadImages() {
        if (imageArray.count == 0) {
            self.photoThumbnail0?.image = nil
        }
        if (imageArray.count >= 1) {
            self.photoThumbnail0.image = imageArray[0]
            self.photoThumbnail1.image = nil
            self.photoThumbnail2.image = nil
        }
        if (imageArray.count >= 2) {
            self.photoThumbnail1.image = imageArray[1]
            self.photoThumbnail2.image = nil
        }
        if (imageArray.count == 3) {
            self.photoThumbnail2.image = imageArray[2]
        }
    }
}