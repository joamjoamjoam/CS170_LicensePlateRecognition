//
//  ViewController.m
//  License Plate Information
//
//  Created by Trent Callan on 11/15/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    NSUInteger tesProgress;
}
@synthesize mainImageView;
@synthesize selectedImage;
@synthesize resultLbl;
@synthesize processPhotoBtn;
@synthesize processingLbl;;
@synthesize processingProgressView;

#pragma mark View Lifecycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    //selectedImage = [[UIImage alloc] init];
}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    
    tesProgress = tesseract.progress;
    [self performSelectorOnMainThread:@selector(updateProgressView) withObject:nil waitUntilDone:YES];
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}
-(void) updateProgressView{
    processingProgressView.progress = tesProgress/100.0;
    [processingProgressView setProgress:processingProgressView.progress animated:YES];
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}



- (IBAction)selectPhotoBtnPressed:(id)sender {
    // image picker
    
    [[self view] endEditing:YES];
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Snap/Upload Photo" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                    picker.delegate = self;
                                    picker.allowsEditing = YES;
                                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                    
                                    [self presentViewController:picker animated:YES completion:NULL];
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    UIAlertAction* selectPhoto = [UIAlertAction actionWithTitle:@"Select Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                    picker.delegate = self;
                                    picker.allowsEditing = YES;
                                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                    
                                    [self presentViewController:picker animated:YES completion:NULL];
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    [alertController addAction:takePhoto];
    [alertController addAction:selectPhoto];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) processImage{
    // Create your G8Tesseract object using the initWithLanguage method:
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng+fra"];
    
    // Optionaly: You could specify engine to recognize with.
    // G8OCREngineModeTesseractOnly by default. It provides more features and faster
    // than Cube engine. See G8Constants.h for more information.
    tesseract.engineMode = G8OCREngineModeTesseractCubeCombined;
    
    // Set up the delegate to receive Tesseract's callbacks.
    // self should respond to TesseractDelegate and implement a
    // "- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract"
    // method to receive a callback to decide whether or not to interrupt
    // Tesseract before it finishes a recognition.
    tesseract.delegate = self;
    [tesseract setPageSegmentationMode:G8PageSegmentationModeSingleWord];
    
    // Optional: Limit the character set Tesseract should try to recognize from
    tesseract.charWhitelist = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-";
    
    // Specify the image Tesseract should recognize on
    
    //tesseract.image = [self scaleImage: [[UIImage imageNamed:@"IMG_2132.JPG"] g8_grayScale] toMaxDimension:640];
    tesseract.image = [selectedImage g8_grayScale];
    
    // Optional: Limit recognition time with a few seconds
    tesseract.maximumRecognitionTime = 60.0;
    
    // Start the recognition
    [tesseract recognize]; 
    
    // Retrieve the recognized text
    NSLog(@"%@", [tesseract recognizedText]);
    resultLbl.text = [NSString stringWithFormat:@"Number is: %@", [tesseract recognizedText]];
    
    // You could retrieve more information about recognized text with that methods:
    NSArray *characterBoxes = [tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelSymbol];
    //NSArray *paragraphs = [tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelParagraph];
    //NSArray *characterChoices = tesseract.characterChoices;
    UIImage *imageWithBlocks = [tesseract imageWithBlocks:characterBoxes drawText:YES thresholded:NO];
    mainImageView.image = [self scaleImage:imageWithBlocks toMaxDimension:300];
    processingProgressView.hidden = YES;
    processingLbl.hidden = YES;
    tesProgress = 0.0;
}

- (IBAction)processPhotoBtnPressed:(id)sender {
    // process
    
    processingProgressView.hidden = NO;
    processingLbl.hidden = NO;
    
    [self performSelectorInBackground:@selector(processImage) withObject:nil];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    selectedImage = chosenImage;
    
    mainImageView.image = [self scaleImage:selectedImage toMaxDimension:300];
    if(chosenImage){
        processPhotoBtn.hidden = NO;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
