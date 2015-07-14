//
//  TWPhotoPickerController.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>

@interface TWPhotoPickerController : UIViewController

@property (nonatomic, copy) void(^cropBlock)(UIImage *image , CLLocationCoordinate2D coord2D);

@end
