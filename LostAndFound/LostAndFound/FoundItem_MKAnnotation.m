//
//  FoundItem_MKAnnotation.m
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FoundItem_MKAnnotation.h"


@implementation FoundItem (FoundItem_MKAnnotation)

- (CLLocationCoordinate2D)coordinate  // part of MKAnnotation protocol
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.locationLat doubleValue];
    coordinate.longitude = [self.locationLon doubleValue];
    return coordinate;
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle 
{
    return self.features;
}

@end
