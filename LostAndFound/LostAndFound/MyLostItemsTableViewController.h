//
//  LostItemsTableViewController.h
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataTableViewController.h"


@interface MyLostItemsTableViewController : CoreDataTableViewController

- initInManagedObjectContext:(NSManagedObjectContext *)context;
@property double itemLatitude;
@property double itemLongitude;

@end
