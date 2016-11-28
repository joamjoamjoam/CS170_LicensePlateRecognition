//
//  citationViewController.m
//  License Plate Information
//
//  Created by Trent Callan on 11/20/16.
//  Copyright © 2016 Trent Callan. All rights reserved.
//

#import "citationTableViewController.h"


@interface citationTableViewController (){
    NSMutableArray* carsDatabase;
}

@end

@implementation citationTableViewController

@synthesize myTableView;


#pragma mark View Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Citations Needed";
    carsDatabase = [self loadObjectWithKey:@"carsDatabase"];
    
    NSLog(@"%lu", [carsDatabase count]);
    NSLog(@"Ran");
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"Did appear View");
    [myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UTableView Datasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [carsDatabase count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    cell.textLabel.text = [[carsDatabase objectAtIndex:indexPath.row] licensePlateString];
    return cell;
}


#pragma mark UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Row selected");
    [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"carSelectedIndexPathRow"];
}


#pragma mark My Helper Methods

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
        tmp = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:key]];
        if(!tmp){
            tmp = [[NSMutableArray alloc] initWithCapacity:0];
            NSLog(@"new");
        }
        NSLog(@"tmp %@",tmp);
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
