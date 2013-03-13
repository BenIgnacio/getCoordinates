//
//  
//  SAMaudioGuide
//
//  Created by Benjamin Ignacio on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@interface MainViewController : UIViewController {
    
@private
    NSMutableArray *items_;
    CLLocationManager *locationManager_;
    UITableView *itemTableView_;
    Item *item_;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UITableView *itemTableView;
@property (nonatomic, retain)  Item *item;

- (IBAction) getCoordinatesButtonPressed: (id) sender;
- (IBAction)showInfo:(id)sender;


@end
