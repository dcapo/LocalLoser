//
//  FoundItem_Create.h
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FoundItem.h"


@interface FoundItem (FoundItem_Create)

+(FoundItem *)foundItemWithFormInfo:(NSDictionary *)formInfo 
           inManagedObjectContext:(NSManagedObjectContext *)context;
@end
