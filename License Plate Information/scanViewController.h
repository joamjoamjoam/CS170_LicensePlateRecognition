//
//  scanViewController.h
//  License Plate Information
//
//  Created by Trent Callan on 11/15/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
#import "myCaptureManager.h"
#import "Cars.h"
@interface scanViewController : UIViewController <UIImagePickerControllerDelegate, G8TesseractDelegate,UINavigationControllerDelegate>

@property UIImage* selectedImage;
@property BOOL imageFromCamera;
@property myCaptureManager* captureManager;
@property UILabel* resultLabel;
@property UIImageView* overlayView;

@end

