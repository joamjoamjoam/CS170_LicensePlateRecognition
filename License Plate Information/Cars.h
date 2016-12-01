//
//  Cars.h
//  License Plate Information
//
//  Created by Trent Callan on 11/20/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Cars : NSObject <NSCoding>

@property NSString* licensePlateString;
@property NSString* make;
@property NSString* model;
@property (strong, nonatomic) UIImage* licensePlateImage;
@property NSString* classType;
@property BOOL cited;

-(id) initWithLicensePlateString: (NSString *) plate classType: (NSString *) passedClassType andLicensePlateImage:(UIImage *) licenseImage;

@end
