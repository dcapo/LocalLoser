//
//  LostItem.h
//  LostAndFound
//
//  Created by Daniel on 6/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LostItem : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * userCell;
@property (nonatomic, retain) NSString * reward;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * locationLat;
@property (nonatomic, retain) NSNumber * locationLon;
@property (nonatomic, retain) NSString * ownershipProof;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * features;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * userEmail;
@property (nonatomic, retain) NSData * thumbnailData;

@end
