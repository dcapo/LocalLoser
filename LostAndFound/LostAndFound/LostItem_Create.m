//
//  LostItem_Create.m
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LostItem_Create.h"


@implementation LostItem (LostItem_Create)

#define USER_INFO @"userInformation"

+(LostItem *)lostItemWithFormInfo:(NSDictionary *)formInfo 
           inManagedObjectContext:(NSManagedObjectContext *)context
{
    LostItem *lostItem = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", [formInfo objectForKey:@"identifier"]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    if (!fetchedObjects || (fetchedObjects.count > 1)) {
        NSLog(@"Error in LostItem_Create");
    } else {
        lostItem = [fetchedObjects lastObject];
        if (!lostItem) {
            lostItem = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
            lostItem.name = [formInfo objectForKey:@"name"];
            lostItem.features = [formInfo objectForKey:@"features"];
            lostItem.ownershipProof = [formInfo objectForKey:@"ownershipProof"];
            lostItem.locationLat = [formInfo objectForKey:@"locationLat"];
            lostItem.locationLon = [formInfo objectForKey:@"locationLon"];
            lostItem.identifier = [formInfo objectForKey:@"identifier"];
            lostItem.userName = [formInfo objectForKey:@"userName"];
            lostItem.userCell = [formInfo objectForKey:@"userCell"];
            lostItem.userEmail = [formInfo objectForKey:@"userEmail"];
            lostItem.photoData = [formInfo objectForKey:@"photoData"];
            lostItem.thumbnailData = [formInfo objectForKey:@"thumbnailData"];
            lostItem.reward = [formInfo objectForKey:@"reward"];
        }
        // if we recently scheduled an autosave, cancel it
        [self cancelPreviousPerformRequestsWithTarget:self selector:@selector(autosave:) object:context];
        // request a new autosave in a few tenths of a second
        [self performSelector:@selector(autosave:) withObject:context afterDelay:0.2];
    }
    return lostItem;
}

// saves a NSManagedObjectContext
// this is performed "after delay," so if a batch of them happen all at the same
//   time, only the last one will actually take effect (since previous ones get canceled)
+ (void)autosave:(id)context
{
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Error in autosave from LostItem_Create: %@ %@", [error localizedDescription], [error userInfo]);
    }
    NSLog(@"Item Saved!");
}


@end
