//
//  FoundItem_Create.m
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011. All rights reserved.
//

#import "FoundItem_Create.h"


@implementation FoundItem (FoundItem_Create)

#define USER_INFO @"userInformation"

+(FoundItem *)foundItemWithFormInfo:(NSDictionary *)formInfo 
             inManagedObjectContext:(NSManagedObjectContext *)context
{
    FoundItem *foundItem = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", [formInfo objectForKey:@"identifier"]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    if (!fetchedObjects || (fetchedObjects.count > 1)) {
        NSLog(@"Error in FoundItem_Create");
    } else {
        foundItem = [fetchedObjects lastObject];
        if (!foundItem) {
            foundItem = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
            foundItem.name = [formInfo objectForKey:@"name"];
            foundItem.features = [formInfo objectForKey:@"features"];
            foundItem.locationLat = [formInfo objectForKey:@"locationLat"];
            foundItem.locationLon = [formInfo objectForKey:@"locationLon"];
            foundItem.identifier = [formInfo objectForKey:@"identifier"];
            foundItem.userName = [formInfo objectForKey:@"userName"];
            foundItem.userCell = [formInfo objectForKey:@"userCell"];
            foundItem.userEmail = [formInfo objectForKey:@"userEmail"];
            foundItem.photoData = [formInfo objectForKey:@"photoData"];
            foundItem.thumbnailData = [formInfo objectForKey:@"thumbnailData"];
        }
        // if we recently scheduled an autosave, cancel it
        [self cancelPreviousPerformRequestsWithTarget:self selector:@selector(autosave:) object:context];
        // request a new autosave in a few tenths of a second
        [self performSelector:@selector(autosave:) withObject:context afterDelay:0.2];
    }
    return foundItem;
}

// saves a NSManagedObjectContext
// this is performed "after delay," so if a batch of them happen all at the same
//   time, only the last one will actually take effect (since previous ones get canceled)
+ (void)autosave:(id)context
{
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Error in autosave from Photo_Flickr: %@ %@", [error localizedDescription], [error userInfo]);
    }
}


@end
