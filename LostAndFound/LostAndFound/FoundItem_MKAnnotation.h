//
//  FoundItem_MKAnnotation.h
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FoundItem.h"
#import <MapKit/MapKit.h>


@interface FoundItem (FoundItem_MKAnnotation) <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (readonly) NSString *title;

@end
