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
@property UIImage* licensePlateImage;

-(id) initWithLicensePlateString: (NSString *) plate make:(NSString *) passedMake model:(NSString *) passedModel andLicensePlateImage:(UIImage *) licenseImage;

@end
