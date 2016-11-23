//
//  myCaptureManager.h
//  License Plate Information
//
//  Created by Trent Callan on 11/17/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface myCaptureManager : NSObject <AVCapturePhotoCaptureDelegate>


@property AVCaptureVideoPreviewLayer* videoPreviewLayer;
@property AVCaptureSession* captureSession;
@property AVCapturePhotoOutput* screenshotOutput;
@property AVCapturePhotoSettings* photoSettings;
@property UIImage* storedImage;


-(void) addVideoPreviewLayer;
-(void) addCaptureLayer;
-(void) addVideoInput;

@end
