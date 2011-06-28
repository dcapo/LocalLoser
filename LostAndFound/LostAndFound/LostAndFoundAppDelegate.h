//
//  LostAndFoundAppDelegate.h
//  LostAndFound
//
//  Created by Daniel Capo
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LostAndFoundAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
