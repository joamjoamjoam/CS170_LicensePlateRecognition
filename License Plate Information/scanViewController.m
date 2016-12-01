//
//  ViewController.m
//  License Plate Information
//
//  Created by Trent Callan on 11/15/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import "scanViewController.h"


@interface scanViewController ()

@end

@implementation scanViewController{
    NSUInteger tesProgress;
    BOOL isAlreadyWaiting;
    NSMutableArray* carsDatabase;
}
@synthesize selectedImage;
@synthesize imageFromCamera;
@synthesize captureManager;
@synthesize resultLabel;
@synthesize overlayView;
@synthesize storedPhoto;
@synthesize myButton;
@synthesize segueButton;

//orient camera correctly

#pragma mark View Lifecycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    isAlreadyWaiting = NO;
    
    // load database for additons
    carsDatabase = [self loadObjectWithKey:@"carsDatabase"];
    
    [self setCaptureManager:[[myCaptureManager alloc] init]];
    
    [[self captureManager] addVideoInput];
    
    [[self captureManager] addVideoPreviewLayer];
    [[self captureManager] addCaptureLayer];
    CGRect layerBound = [[[self view] layer] bounds];
    
    [[[self captureManager] videoPreviewLayer] setBounds:layerBound];
    [[[self captureManager] videoPreviewLayer] setPosition:CGPointMake(CGRectGetMidX(layerBound),CGRectGetMidY(layerBound))];
    [[[self view] layer] addSublayer:[[self captureManager] videoPreviewLayer]];
    
    
    // create our overlay layer
    overlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay.png"]];
    // aspect ratio of license plate in cali is 2L:1W
    int aspectRatioScaleFactor = 2/1;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float screenWidth = screenBounds.size.width;
    float screenHeight = screenBounds.size.height;
    
    NSLog(@"Screen Width = %.0f and Heighth = %.0f", screenWidth, screenHeight);
    
    float horizontalStretchFactor = .4; // 60 % of width of screen taken up
    
    int width = ( screenWidth * horizontalStretchFactor);
    int height = width / aspectRatioScaleFactor;
    //overlayView.frame = CGRectMake((0 + (414*.05)), (0 + (700 * .35)), (414*.9), (700 * .3));
    
    overlayView.frame = CGRectMake((0 + ((screenWidth - width)/2)), (0 + ((screenHeight - height)/2)), width, height);
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.opaque = NO;
    [[self view] addSubview:overlayView];
    
    // create scan overlay button
    float myButtonWidthScaleFactor = .7; // percentage of overlay view width
    int myButtonWidth = (myButtonWidthScaleFactor * overlayView.frame.size.width);
    int myButtonHeight = myButtonWidth * .3; // 16:9 Aspect Ratio
    myButton = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth/2 - myButtonWidth/2), (overlayView.frame.origin.y + overlayView.frame.size.height + 20), myButtonWidth, myButtonHeight)];
    [myButton setImage:[UIImage imageNamed:@"button.jpg"] forState:UIControlStateNormal];
    [myButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:myButton];
    
    // create segue overlay button
    int segueButtonWidth = 60;
    int segueButtonHeigth = segueButtonWidth/2;
    segueButton = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - (segueButtonWidth + 10)), 10, segueButtonWidth, segueButtonHeigth)];
    [segueButton setImage:[UIImage imageNamed:@"carsButton.jpg"] forState:UIControlStateNormal];
    [segueButton addTarget:self action:@selector(citationBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:segueButton];
    
    
    resultLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth/2 - 60), (screenHeight * .15), 200, 30)];
    resultLabel.hidden = YES;
    resultLabel.backgroundColor = [UIColor clearColor];
    resultLabel.text = @"Processing ...";
    resultLabel.font = [UIFont fontWithName:@"Courier" size:18.0];
    resultLabel.textColor = [UIColor redColor];
    
    [[self view] addSubview:resultLabel];
    
    [[captureManager captureSession] startRunning];
    
    UIImage* tmpImage = [UIImage imageNamed:@"IMG_2132.JPG"];
    
    Cars* tmpCar = [[Cars alloc] initWithLicensePlateString:@"2DGT4568" classType:[self isValidLicensePlate:@"2DGT4568"] andLicensePlateImage:tmpImage];
    
    NSLog(@"set image = %@", tmpCar.licensePlateImage);
    
    [self addCarToDatabase:tmpCar];
    
    Cars* tmpCar1 = [[Cars alloc] initWithLicensePlateString:@"2D244568" classType:[self isValidLicensePlate:@"2D244568"] andLicensePlateImage:[UIImage imageNamed:@"IMG_2132.JPG"]];
    
    [self addCarToDatabase:tmpCar1];
    
    Cars* tmpCar2 = [[Cars alloc] initWithLicensePlateString:@"22544568" classType:[self isValidLicensePlate:@"22544568"] andLicensePlateImage:[UIImage imageNamed:@"IMG_2132.JPG"]];
    
    [self addCarToDatabase:tmpCar2];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark IBAction Methods


-(void) scanButtonPressed{
    // take picture and store it as UIImage
    
    // disable button here
    myButton.hidden = YES;
    segueButton.hidden = YES;
    
    NSDictionary* settingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    AVCapturePhotoSettings* photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:settingsDict];
    
    resultLabel.text = @"Processing ...";
    resultLabel.hidden = NO;
    
    [captureManager.screenshotOutput capturePhotoWithSettings:photoSettings delegate:self];
    // perform any actions on UIImage crop it and make it easy for tessaact to read
}

- (void) citationBtnPressed{
    
    //captureManager.videoDevice.torchMode = AVCaptureTorchModeOff;
    [self performSegueWithIdentifier:@"scanToCitationSegue" sender:self];
}

- (void) processImage: (UIImage*) image{
    // Create your G8Tesseract object using the initWithLanguage method:
    BOOL addedCar = NO;
    NSString* type = @"";
    //captureManager.videoDevice.torchMode = AVCaptureTorchModeOff;
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng+fra"];
    
    tesseract.engineMode = G8OCREngineModeTesseractCubeCombined;
    tesseract.delegate = self;
    [tesseract setPageSegmentationMode:G8PageSegmentationModeSingleWord];
    tesseract.charWhitelist = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-";
    tesseract.image = [image g8_grayScale];
    tesseract.maximumRecognitionTime = 60.0;
    
    // set scan frame to correct position whole thing if not from camera or (x,y,w,h) = (21,257,372,186) if from camera
    int monthAdjInPixels = 50 * 2.6087;
    // divide by scale factor to turn pixels to points
    tesseract.rect = CGRectMake(0, monthAdjInPixels, image.size.width, image.size.height - monthAdjInPixels);
    
    [tesseract recognize];
    
    // Retrieve the recognized text
    NSMutableString* recognizedText = [[tesseract recognizedText] mutableCopy];
    NSLog(@"First recognized text = %@", recognizedText);
    NSArray *characterBoxes = [tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelSymbol];
    UIImage *imageWithBlocks = [tesseract imageWithBlocks:characterBoxes drawText:NO thresholded:NO];
    
    overlayView.image = imageWithBlocks;
    
    recognizedText = [self cleanUpLicensePlateString:recognizedText];
    
    NSLog(@"Scrubbed recognized text = %@", recognizedText);
    
    type = [self isValidLicensePlate:recognizedText];
    
    if (![type isEqualToString:@"NO"]){
        // valid license plate add to cars Database and save
        NSLog(@"Adding car.");
        Cars* tmp = [[Cars alloc] initWithLicensePlateString:recognizedText classType: type andLicensePlateImage:image];
        addedCar = [self addCarToDatabase:tmp];
        if (addedCar) {
            resultLabel.text = [NSString stringWithFormat:@"Number is: %@ and car was added.", recognizedText];
        }
        else{
            resultLabel.text = [NSString stringWithFormat:@"Number is: %@ but is alredy in database.", recognizedText];
        }
        
    }
    else{
        resultLabel.text = [NSString stringWithFormat:@"No License Plate Found. Try Again."];
    }
    
    // You could retrieve more information about recognized text with that methods:
    
    
    tesProgress = 0.0;
    if (!isAlreadyWaiting) {
        [self performSelector:@selector(reenableView) withObject:nil afterDelay:5];
        isAlreadyWaiting = YES;
    }
    
    
}

- (void) reenableView{
    resultLabel.hidden = YES;
    isAlreadyWaiting = NO;
    overlayView.image = [UIImage imageNamed:@"overlay.png"];
    // enable button here
    myButton.hidden = NO;
    segueButton.hidden = NO;
    //captureManager.videoDevice.torchMode = AVCaptureTorchModeOn;
}

- (void) resetOverlayView{
}

- (UIImage *) scaleImage: (UIImage *) image toMaxDimension: (CGFloat) maxDimension {
    
    CGSize scaledSize = CGSizeMake(maxDimension, maxDimension);
    CGFloat scaleFactor = 0;
    
    if (image.size.width > image.size.height) {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.width = maxDimension;
        scaledSize.height = scaledSize.width * scaleFactor;
    }
    else {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.height = maxDimension;
        scaledSize.width = scaledSize.height * scaleFactor;
    }
    
    UIGraphicsBeginImageContext(scaledSize);
    [image drawInRect:(CGRectMake(0, 0, scaledSize.width, scaledSize.height))];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

#pragma mark Delegate Methods

#pragma mark Tesseract Delegate Methods
- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    
    tesProgress = tesseract.progress;
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

#pragma mark AVCapturePhotoDelegate Methods

-(void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error
{
    
    NSLog(@"delegate called");
    if (error) {
        NSLog(@"error : %@", error);
    }
    
    if (photoSampleBuffer) {
        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        UIImage *image = [UIImage imageWithData:data];
        
        self.storedPhoto = image;
        
        // Test A photo Here
        //self.storedPhoto = [UIImage imageNamed:@"testCar.JPG"];
        
        NSLog(@"image width = %f and height is %f",self.storedPhoto.size.width, self.storedPhoto.size.height);
        
        // test image being captured
//        CGRect screenBounds = [[UIScreen mainScreen] bounds];
//        float screenWidth = screenBounds.size.width;
//        float screenHeight = screenBounds.size.height;
//        UIImageView* test = [[UIImageView alloc] initWithImage:storedPhoto];
//        test.frame = CGRectMake(0, 0, screenWidth, screenHeight);
//        [[self view] addSubview:test];
//        [[self view] bringSubviewToFront:test];
        
        
        UIImage* croppedScanImage = [self cropImage:storedPhoto toRectInPoints:overlayView.frame];
        
        UIImage* processedScanImage = [self cleanUpImageForProcessing:croppedScanImage];
        
        // test
        //overlayView.image = processedScanImage;
        
        [self processImage:processedScanImage];
    }
}
#pragma mark My Helper Methods

- (NSString *) isValidLicensePlate:(NSString *) recognizedText{
    NSError* error;
    NSRegularExpression* validMotorcylcePlateRegExp = [NSRegularExpression regularExpressionWithPattern:@"[0-9][A-Z][0-9][0-9][0-9][0-9][0-9]" options:0 error:&error];
    
    NSRegularExpression* validCommercialPlateRegExp = [NSRegularExpression regularExpressionWithPattern:@"[0-9][A-Z][A-Z][A-Z][0-9][0-9][0-9]" options:0 error:&error];
    
    NSRegularExpression* validPublicPlateRegExp = [NSRegularExpression regularExpressionWithPattern:@"[0-9][0-9][0-9][0-9][0-9][0-9][0-9]" options:0 error:&error];
    
    NSLog(@"Testing string: %@", recognizedText);
    
    if(recognizedText && [recognizedText length] == 7){
        if([[validCommercialPlateRegExp matchesInString:recognizedText options:0 range:NSMakeRange(0, [recognizedText length])] count] > 0){
            NSLog(@"At least 1 Commercial Match.");
            return @"Commercial";
        }
        else if([[validMotorcylcePlateRegExp matchesInString:recognizedText options:0 range:NSMakeRange(0, [recognizedText length])] count] > 0){
            NSLog(@"At least 1 Motorcycle Match.");
            return @"Motorcycle";
        }
        if([[validPublicPlateRegExp matchesInString:recognizedText options:0 range:NSMakeRange(0, [recognizedText length])] count] > 0){
            NSLog(@"At least 1 Public Match.");
            return @"Public";
        }
    }
    
    NSLog(@"No Match");
    return @"NO";
}

- (BOOL) addCarToDatabase: (Cars *) tmpCar{
    
    for (Cars* car in carsDatabase){
        if([tmpCar.licensePlateString isEqualToString:car.licensePlateString]){
            NSLog(@"car already exists"); 
            return NO;
        }
    }
    
    NSLog(@"tmpCar image = %@", tmpCar.licensePlateImage);
    
    [carsDatabase addObject:tmpCar];
    NSLog(@"Car db = %@", carsDatabase);
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:carsDatabase];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"carsDatabase"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (void) setAppleObject: (id) tmp forKey: (NSString *) key{
    [[NSUserDefaults standardUserDefaults] setObject: tmp forKey: key];
    //[[NSUserDefaults standardUserDefaults] synchronize];
}

-(id) loadObjectWithKey:(NSString *) key{
    id tmp;
    
    if ([key isEqualToString:@"carsDatabase"]){
        tmp = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:key]];
        if(!tmp){
            tmp = [[NSMutableArray alloc] initWithCapacity:0];
            NSLog(@"new");
        }
        NSLog(@"tmp %@",tmp);
    }
    else{
        tmp = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    return tmp;
}

- (UIImage *) cropImage: (UIImage *) img toRectInPoints: (CGRect) clipRect{
    
    NSLog(@"Cropping image w frame (%.0f,%.0f) to rect (%.0f,%.0f)", img.size.width,img.size.height,clipRect.size.width,clipRect.size.height);
    
    
    CGRect transformedRect = CGRectMake((clipRect.origin.x * 2.6087), (clipRect.origin.y * 2.6087), (clipRect.size.width * 2.6087), (clipRect.size.height * 2.6087));
    
    NSLog(@"Cropping image w frame (%.0f,%.0f) to tranformed rect (%.0f,%.0f)", img.size.width,img.size.height,transformedRect.size.width,transformedRect.size.height);
    
    
    CGImageRef imageReference = CGImageCreateWithImageInRect([img CGImage], transformedRect);
    
    return [UIImage imageWithCGImage:imageReference scale:1 orientation:img.imageOrientation];
}

- (UIImage *) cleanUpImageForProcessing: (UIImage *) img{
    CGImageRef imageRef = img.CGImage;
    CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    UInt8* pixelBuffer = (UInt8 *) CFDataGetBytePtr(dataRef);
    
    for (int i = 0; i < CFDataGetLength(dataRef); i+=4) {
        [self processPixelWithBuffer:pixelBuffer andIndex:i];
    }
    CGContextRef conRef = CGBitmapContextCreate(pixelBuffer, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
    
    CGImageRef imgRef = CGBitmapContextCreateImage(conRef);
    
    return [UIImage imageWithCGImage:imgRef scale:1 orientation:img.imageOrientation];
    
    
    return img;
}

- (void) processPixelWithBuffer: (UInt8 *) buffer andIndex: (int) i{
    int r = i;
    int g = i + 1;
    int b = i + 2;
    
    float red = buffer[r];
    float green = buffer[g];
    float blue = buffer[b];
    
    // convert to hsv from rgb
    
    float rprime = red/255;
    float gprime = green/255;
    float bprime = blue/255;
    
    float cmax = [self maxValueForRed:rprime green:gprime andBlue:bprime];
    float cmin = [self minValueForRed:rprime green:gprime andBlue:bprime];
    
    float delta = cmax - cmin;
    float hue,sat,value;
    // Hue
    if(delta == 0){
        hue = 0;
    }
    else if(cmax == rprime){
        hue = 60 * ((gprime - bprime)/delta);
    }
    else if(cmax == gprime){
        hue = 60 * (((bprime - rprime)/delta) + 2);
    }
    else if(cmax == bprime){
        hue = 60 * (((rprime - gprime)/delta) + 4);
    }
    
    if (hue < 0) {
        hue+=360;
    }
    // Saturation
    if (cmax == 0) {
        sat = 0;
    }
    else{
        sat = delta/cmax;
    }
    //Value
    value = cmax;
    
    if((hue > 198 && hue < 270)){
        //NSLog(@"Colors for pixel is (r,g,b) = (%.0f,%.0f,%.0f)", red,green,blue);
        
        //NSLog(@"Colors for pixel is (h,s,v) = (%.0f,%.2f,%.2f)", hue, sat, value);
    }
    
    
    if( (hue > 198 && hue < 270) && sat > .3 && (value > .4 && value < .7)){      // if pixel is blue ish then set it black
        buffer[r] = 0;
        buffer[g] = 0;
        buffer[b] = 0;
    }
    else{      // else set it white
        buffer[r] = 255;
        buffer[g] = 255;
        buffer[b] = 255;
    }
}

- (float) maxValueForRed: (float) r green: (float) g andBlue: (float) blue{
    float max = 0;
    if (r >= g) {
        max = r;
    }
    else{
        max = g;
    }
    
    if( max < blue){
        max = blue;
    }
    else{
        // max is already the max
    }
    
    return max;
}

- (float) minValueForRed: (float) r green: (float) g andBlue: (float) blue{
    float min = 1000;
    if (r <= g) {
        min = r;
    }
    else{
        min = g;
    }
    
    if( min > blue){
        min = blue;
    }
    else{
        // min is already the min
    }
    return min;
}

-(NSMutableString *)cleanUpLicensePlateString: (NSMutableString *) recognizedText{
    for (int i = 0; i < [recognizedText length]; i++) {
        if (i == 1 || i == 2 || i == 3) {
            if([[recognizedText substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"2"]){
                recognizedText = [[recognizedText stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:@"Z"] mutableCopy];
            }
        }
        else{
            if([[recognizedText substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"Z"]){
                recognizedText = [[recognizedText stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:@"2"] mutableCopy];
            }
        }
    }
    return  recognizedText;
}

@end
