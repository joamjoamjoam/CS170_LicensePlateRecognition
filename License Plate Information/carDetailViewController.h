//
//  carDetailViewController.h
//  License Plate Information
//
//  Created by Trent Callan on 11/20/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cars.h"

@interface carDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *carMakeLabel;
@property (strong, nonatomic) IBOutlet UILabel *carModelLabel;
@property (strong, nonatomic) IBOutlet UILabel *carLicensePlateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *carImageView;

@end
