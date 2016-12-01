//
//  myCaptureManager.m
//  License Plate Information
//
//  Created by Trent Callan on 11/17/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import "myCaptureManager.h"

@implementation myCaptureManager

@synthesize captureSession;
@synthesize videoPreviewLayer;
@synthesize screenshotOutput;
@synthesize videoDevice;

-(id) init{
    self = [super init];
    if (self) {
        captureSession = [[AVCaptureSession alloc] init];
    }
    
    return self;
}

-(void) addVideoPreviewLayer{
    [self setVideoPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
    [[self videoPreviewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    
}


-(void) addVideoInput{
    videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (videoDevice) {
        NSError *error;
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:videoIn]){
                [[self captureSession] addInput:videoIn];
                [videoDevice lockForConfiguration:nil];
                //[videoDevice setTorchMode:AVCaptureTorchModeOn];
            }
        }
    }
}

- (void) addCaptureLayer{
    screenshotOutput = [[AVCapturePhotoOutput alloc] init];
    [[self captureSession] addOutput:screenshotOutput];
    [screenshotOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
}
@end
