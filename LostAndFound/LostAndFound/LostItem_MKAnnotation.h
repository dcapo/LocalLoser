//
//  LostItem_MKAnnotation.h
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LostItem.h"
#import <MapKit/MapKit.h>


@interface LostItem (LostItem_MKAnnotation) <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (readonly) NSString *title;

@end
