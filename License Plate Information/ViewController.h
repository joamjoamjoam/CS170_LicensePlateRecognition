//
//  ViewController.h
//  License Plate Information
//
//  Created by Trent Callan on 11/15/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
@interface ViewController : UIViewController <UIImagePickerControllerDelegate, G8TesseractDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;
@property UIImage* selectedImage;
@property (strong, nonatomic) IBOutlet UILabel *resultLbl;
@property (strong, nonatomic) IBOutlet UIButton *processPhotoBtn;
@property (strong, nonatomic) IBOutlet UILabel *processingLbl;
@property (strong, nonatomic) IBOutlet UIProgressView *processingProgressView;

- (IBAction)selectPhotoBtnPressed:(id)sender;
- (IBAction)processPhotoBtnPressed:(id)sender;


@end

