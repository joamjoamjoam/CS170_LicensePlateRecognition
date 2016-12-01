//
//  carDetailViewController.m
//  License Plate Information
//
//  Created by Trent Callan on 11/20/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import "carDetailViewController.h"

@interface carDetailViewController (){
    NSMutableArray* carsDatabase;
    Cars* carSelected;
    NSInteger selectedCarIndexPathRow;
    
}

@end

@implementation carDetailViewController
@synthesize carImageView;
@synthesize carLicensePlateLabel;
@synthesize carCitedSwitch;
@synthesize carClassTypeLabel;
@synthesize carMakeTextField;
@synthesize carModelTextField;
- (void)viewDidLoad {
    [super viewDidLoad];
    carsDatabase =  [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"carsDatabase"]];//[self loadObjectWithKey:@"carsDatabase"];
    selectedCarIndexPathRow = [[NSUserDefaults standardUserDefaults] integerForKey:@"carSelectedIndexPathRow"];
    
    NSLog(@"");
    
    carSelected = [carsDatabase objectAtIndex:selectedCarIndexPathRow];
    
    carMakeTextField.text = carSelected.make;
    carModelTextField.text = carSelected.model;
    
    NSLog(@"car image = %@", carSelected.licensePlateImage);
    
    carImageView.image = carSelected.licensePlateImage;
    carLicensePlateLabel.text = carSelected.licensePlateString;
    carClassTypeLabel.text = carSelected.classType;
    [carCitedSwitch setOn:carSelected.cited];
    
    
}

- (IBAction)carCitedSwitchValueChanged:(id)sender{
    carSelected.cited = !carSelected.cited;
    [carsDatabase replaceObjectAtIndex:selectedCarIndexPathRow withObject:carSelected];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:carsDatabase];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"carsDatabase"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) addCarToDatabase: (Cars *) tmpCar{
    
    for (Cars* car in carsDatabase){
        if([tmpCar.licensePlateString isEqualToString:car.licensePlateString]){
            return NO;
        }
    }
    
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
    NSMutableArray* tmp;
    
    if ([key isEqualToString:@"carsDatabase"]){
        tmp = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:key]];
        if(!tmp){
            tmp = [[NSMutableArray alloc] initWithCapacity:0];
            NSLog(@"new");
        }
        NSLog(@"tmp %@",tmp);
    }
    return tmp;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"Did End Editing");
    carSelected.make = carMakeTextField.text;
    carSelected.model = carModelTextField.text;
    [carsDatabase replaceObjectAtIndex:selectedCarIndexPathRow withObject:carSelected];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:carsDatabase];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"carsDatabase"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
