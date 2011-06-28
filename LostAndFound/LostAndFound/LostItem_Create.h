//
//  LostItem_Create.h
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LostItem.h"


@interface LostItem (LostItem_Create)

+(LostItem *)lostItemWithFormInfo:(NSDictionary *)formInfo 
           inManagedObjectContext:(NSManagedObjectContext *)context;
@end
