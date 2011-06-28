//
//  FoundItemInfoPageViewController.h
//  LostAndFound
//
//  Created by Daniel on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoundItem.h"


@interface FoundItemInfoPageViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, retain) FoundItem *foundItem;
@property (nonatomic, retain) NSManagedObjectContext *context;
@end
