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
@synthesize photoSettings;
@synthesize storedImage;

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
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (videoDevice) {
        NSError *error;
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:videoIn]){
                [[self captureSession] addInput:videoIn];
            }
        }
    }
}

- (void) addCaptureLayer{
    screenshotOutput = [[AVCapturePhotoOutput alloc] init];
    photoSettings = [AVCapturePhotoSettings photoSettings];
}

-(void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error
{
    if (error) {
        NSLog(@"error : %@", error);
    }
    
    if (photoSampleBuffer) {
        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        UIImage *image = [UIImage imageWithData:data];
        
        storedImage = image;
    }
}
@end
