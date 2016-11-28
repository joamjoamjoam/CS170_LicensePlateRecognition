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
@synthesize classType;
@synthesize cited;

-(id) initWithLicensePlateString: (NSString *) plate classType: (NSString *) passedClassType andLicensePlateImage:(UIImage *) licenseImage{
    
    self = [super init];
    if (self) {
        self.licensePlateString = plate;
        self.licensePlateImage = licenseImage;
        self.classType = passedClassType;
        self.cited = NO;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self.licensePlateString = [aDecoder decodeObjectForKey:@"licensePlateString"];
    self.make = [aDecoder decodeObjectForKey:@"make"];
    self.model = [aDecoder decodeObjectForKey:@"model"];
    self.licensePlateImage = [aDecoder decodeObjectForKey:@"licensePlateImage"];
    self.classType = [aDecoder decodeObjectForKey:@"classType"];
    self.cited = [aDecoder decodeBoolForKey:@"cited"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.licensePlateString forKey:@"licensePlateString"];
    [coder encodeObject:self.make forKey:@"make"];
    [coder encodeObject:self.model forKey:@"model"];
    [coder encodeObject:self.licensePlateImage forKey:@"licensePlateImage"];
    [coder encodeObject:self.classType forKey:@"classType"];
    [coder encodeBool:self.cited forKey:@"cited"];
}

@end
