//
//  carDetailViewController.h
//  License Plate Information
//
//  Created by Trent Callan on 11/20/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cars.h"

@interface carDetailViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel *carLicensePlateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *carCitedSwitch;
@property (strong, nonatomic) IBOutlet UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UITextField *carMakeTextField;
@property (weak, nonatomic) IBOutlet UITextField *carModelTextField;
@property (weak, nonatomic) IBOutlet UILabel *carClassTypeLabel;
- (IBAction)carCitedSwitchValueChanged:(id)sender;

@end
