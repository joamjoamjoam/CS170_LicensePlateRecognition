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
    
    float horizontalStretchFactor = .6; // 60 % of width of screen taken up
    
    int width = ( screenWidth * horizontalStretchFactor);
    int height = width / aspectRatioScaleFactor;
    //overlayView.frame = CGRectMake((0 + (414*.05)), (0 + (700 * .35)), (414*.9), (700 * .3));
    
    overlayView.frame = CGRectMake((0 + ((screenWidth - width)/2)), (0 + ((screenHeight - height)/2)), width, height);
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.opaque = NO;
    [[self view] addSubview:overlayView];
    
    // create scan overlay button
    UIButton* myButton = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth/2 - 60), screenHeight - 90, 120, 60)];
    [myButton setImage:[UIImage imageNamed:@"button.jpg"] forState:UIControlStateNormal];
    [myButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:myButton];
    
    // create segue overlay button
    int buttonWidth = 60;
    UIButton* segueButton = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - (buttonWidth + 10)), (screenHeight + 10), 60, 30)];
    [myButton setImage:[UIImage imageNamed:@"button.jpg"] forState:UIControlStateNormal];
    [myButton addTarget:self action:@selector(citationBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:segueButton];
    
    
    resultLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth/2 - 60), (screenHeight * .15), 200, 30)];
    resultLabel.hidden = YES;
    resultLabel.backgroundColor = [UIColor clearColor];
    resultLabel.text = @"Processing ...";
    resultLabel.font = [UIFont fontWithName:@"Courier" size:18.0];
    resultLabel.textColor = [UIColor redColor];
    
    [[self view] addSubview:resultLabel];
    
    [[captureManager captureSession] startRunning];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark IBAction Methods


-(void) scanButtonPressed{
    // take picture and store it as UIImage
    [captureManager.screenshotOutput capturePhotoWithSettings:captureManager.photoSettings delegate:captureManager];
    UIImage* scanImageFull = captureManager.storedImage;
    // perform any actions on UIImage crop it and make it easy for tessaact to read
    UIImage* processedScanImage;
    // initiate scan on image
    
    // test
    overlayView.image = scanImageFull;
    
    [self processImage:processedScanImage];
}

- (void) citationBtnPressed{
    
    [self performSegueWithIdentifier:@"scanToCitationSegue" sender:self];
}

- (void) processImage: (UIImage*) image{
    // Create your G8Tesseract object using the initWithLanguage method:
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    resultLabel.hidden = NO;
    
    tesseract.engineMode = G8OCREngineModeTesseractCubeCombined;
    tesseract.delegate = self;
    [tesseract setPageSegmentationMode:G8PageSegmentationModeSingleWord];
    tesseract.charWhitelist = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-";
    tesseract.image = [image g8_grayScale];
    tesseract.maximumRecognitionTime = 60.0;
    
    // set scan frame to correct position whole thing if not from camera or (x,y,w,h) = (21,257,372,186) if from camera
    tesseract.rect = CGRectMake(21, 257, 372, 186);
    
    [tesseract recognize];
    
    // Retrieve the recognized text
    NSLog(@"%@", [tesseract recognizedText]);
    NSArray *characterBoxes = [tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelSymbol];
    UIImage *imageWithBlocks = [tesseract imageWithBlocks:characterBoxes drawText:YES thresholded:NO];
    
    if ([self isValidLicensePlate:[tesseract recognizedText]]){
        // valid license plate add to cars Database and save
        Cars* tmp = [[Cars alloc] initWithLicensePlateString:[tesseract recognizedText] make:@"Chevy" model:@"Camaro" andLicensePlateImage:imageWithBlocks];
        [self addCarToDatabase:tmp];
        
    }
    resultLabel.text = [NSString stringWithFormat:@"Number is: %@", tesseract.recognizedText];
    
    // You could retrieve more information about recognized text with that methods:
    
    
    tesProgress = 0.0;
    if (!isAlreadyWaiting) {
        [self performSelector:@selector(hideLabel) withObject:nil afterDelay:5];
        isAlreadyWaiting = YES;
    }
}

- (void) hideLabel{
    resultLabel.hidden = YES;
    isAlreadyWaiting = NO;
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

#pragma mark UIImagePicker Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    NSLog(@"Image Width is: %.0f and heighth is: %.0f", chosenImage.size.width/3,chosenImage.size.height/3);
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        imageFromCamera = YES;
    }
    else{
        imageFromCamera = NO;
    }
    
    selectedImage = chosenImage;
    
    // image should be 372W(x) x 186L(y)
    //mainImageView.image = [self scaleImage:selectedImage toMaxDimension:372];
    
    if(chosenImage){
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark Tesseract Delegate Methods
- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    
    tesProgress = tesseract.progress;
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}
#pragma mark My Helper Methods

- (BOOL) isValidLicensePlate:(NSString *) recognizedText{
    NSError* error;
    NSRegularExpression* validClasscCAPlateRegExp = [NSRegularExpression regularExpressionWithPattern:@"[0-9][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9]" options:0 error:&error];
    
    NSLog(@"Testing string: %@", recognizedText);
    
    if([validClasscCAPlateRegExp matchesInString:recognizedText options:0 range:NSMakeRange(0, [recognizedText length])]){
        NSLog(@"At least 1 Match.");
        return YES;
    }
    NSLog(@"No Match");
    return NO;
}

- (void) addCarToDatabase: (Cars *) tmpCar{
    [carsDatabase addObject:tmpCar];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:carsDatabase];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"carsDatabase"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setAppleObject: (id) tmp forKey: (NSString *) key{
    [[NSUserDefaults standardUserDefaults] setObject: tmp forKey: key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id) loadObjectWithKey:(NSString *) key{
    id tmp;
    
    if ([key isEqualToString:@"carsDatabase"]){
        if(!carsDatabase){
            carsDatabase = [[NSMutableArray alloc] initWithCapacity:0];
        }
        else{
            carsDatabase = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:key]];
        }
    }
    else{
        tmp = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    return tmp;
}


@end
