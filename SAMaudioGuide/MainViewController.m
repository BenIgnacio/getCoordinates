//
//  MainViewController.m
//  SAMaudioGuide
//
//  Created by Benjamin Ignacio on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "Item.h"

@implementation MainViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize items = items_;
@synthesize locationManager = locationManager_;
@synthesize itemTableView = itemTableView_;
@synthesize item = item_;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //Core data loading...
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item"  inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error;
        NSLog(@"Core data error!");
    }
    
    self.items = mutableFetchResults;
    
    [self.itemTableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [items_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    Item *item = [items_ objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%i,   %i",
                           [item.id intValue],
                           [item.heading intValue]];   
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Save the selected item.
    item_ = [items_ objectAtIndex:indexPath.row];
}

- (IBAction) getCoordinatesButtonPressed: (id) sender {
      
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];

/* Try doing this in didUpdataLocation    
    //Get location & heading
    CLLocation *curPos = self.locationManager.location;
    CLHeading *heading = self.locationManager.heading;

    //Don't use cache data. Restart locationManager if locationManager time stamp is older than a second.
    NSTimeInterval curPosAge = [curPos.timestamp timeIntervalSinceNow];
    NSTimeInterval headingAge = [heading.timestamp timeIntervalSinceNow];
    if (curPosAge > 2 || headingAge > 2) {
        //restart location service to get newest coordinates
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"locationManager Restarted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

        //try again
        curPos = self.locationManager.location;
        heading = self.locationManager.heading;
    }
    
    if (curPos == nil) {
        item_.latitude = [NSNumber numberWithDouble:1];
        item_.longitude = [NSNumber numberWithDouble:1];
    } else {
        //item_ is set in tableView didSelectRowAtIndexPath
        item_.latitude = [NSNumber numberWithDouble:curPos.coordinate.latitude];
        item_.longitude = [NSNumber numberWithDouble:curPos.coordinate.longitude];
        item_.heading = [NSNumber numberWithInt:heading.trueHeading];
    }

    //refresh the tableview
    [itemTableView_ reloadData];
*/
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation]; //Save battery.
    [self.locationManager stopUpdatingHeading]; 
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Core location
//Core location methods
- (CLLocationManager*) locationManager {
    if (locationManager_ == nil) {
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager_.distanceFilter = kCLDistanceFilterNone;
        locationManager_.delegate = self;
    }
    return locationManager_;
}



- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Display alert.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't get coordinates." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    double latitude = newLocation.coordinate.latitude;
    double longitude = newLocation.coordinate.longitude;
    double accuracy = newLocation.horizontalAccuracy;
    //double altitude = newLocation.altitude; //can't use altitude. It requires a gps w/c doesn't work indoors
    //double altAccuracy = newLocation.verticalAccuracy;
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
 
    //How long does it take to get to 30 meter accuracy?
    //Is it enough?
    //Is it current?

    NSLog(@"%f, %f", accuracy, locationAge);
    //NSLog(@"%f, %f, %f, %f", altitude, altAccuracy, accuracy, locationAge);
    
//    item_.latitude = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
//    item_.longitude = [NSNumber numberWithDouble:newLocation.coordinate.longitude];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //int trueHeading = newHeading.trueHeading;
    //NSLog(@"HEADING %f, ACCURACY %f", newHeading.trueHeading, newHeading.headingAccuracy);
}

@end
