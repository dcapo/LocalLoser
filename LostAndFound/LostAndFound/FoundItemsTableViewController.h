//
//  FoundItemsTableViewController.h
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataTableViewController.h"


@interface FoundItemsTableViewController : CoreDataTableViewController

@property double itemLatitude;
@property double itemLongitude;
- initInManagedObjectContext:(NSManagedObjectContext *)context;

@end