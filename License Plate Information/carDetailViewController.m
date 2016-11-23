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
    NSIndexPath* selectedCarIndexPath;
    
}

@end

@implementation carDetailViewController
@synthesize carImageView;
@synthesize carMakeLabel;
@synthesize carModelLabel;
@synthesize carLicensePlateLabel;
- (void)viewDidLoad {
    [super viewDidLoad];
    carsDatabase = [self loadObjectWithKey:@"carsDatabase"];
    selectedCarIndexPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedCarIndexPath"];
    carSelected = [carsDatabase objectAtIndex:selectedCarIndexPath.row];
    
    
    carImageView.image = carSelected.licensePlateImage;
    carMakeLabel.text = carSelected.make;
    carModelLabel.text = carSelected.model;
    carLicensePlateLabel.text = carSelected.licensePlateString;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
