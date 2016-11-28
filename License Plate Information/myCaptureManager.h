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

@interface myCaptureManager : NSObject 


@property AVCaptureVideoPreviewLayer* videoPreviewLayer;
@property AVCaptureSession* captureSession;
@property AVCapturePhotoOutput* screenshotOutput;
@property AVCaptureDevice* videoDevice;


-(void) addVideoPreviewLayer;
-(void) addCaptureLayer;
-(void) addVideoInput;

@end
