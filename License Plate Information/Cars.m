//
//  Cars.m
//  License Plate Information
//
//  Created by Trent Callan on 11/20/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import "Cars.h"

@implementation Cars

@synthesize licensePlateString;
@synthesize make;
@synthesize model;
@synthesize licensePlateImage;

-(id) initWithLicensePlateString: (NSString *) plate make:(NSString *) passedMake model:(NSString *) passedModel andLicensePlateImage:(UIImage *)plateImage{
    
    self = [super init];
    if (self) {
        self.licensePlateString = plate;
        self.make = passedMake;
        self.model = passedModel;
        self.licensePlateImage = plateImage;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self.licensePlateString = [aDecoder decodeObjectForKey:@"licensePlateString"];
    self.make = [aDecoder decodeObjectForKey:@"make"];
    self.model = [aDecoder decodeObjectForKey:@"model"];
    self.licensePlateImage = [aDecoder decodeObjectForKey:@"licensePlateImage"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.licensePlateString forKey:@"licensePlateString"];
    [coder encodeObject:self.make forKey:@"make"];
    [coder encodeObject:self.model forKey:@"model"];
    [coder encodeObject:self.licensePlateImage forKey:@"licensePlateImage"];
}

@end
