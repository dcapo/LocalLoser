//
//  LostItemInfoPageViewController.h
//  LostAndFound
//
//  Created by Daniel on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LostItem.h"


@interface LostItemInfoPageViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, retain) LostItem *lostItem;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property BOOL isMyItem;
@end
