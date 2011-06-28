//
//  DraggablePinAnnotation.h
//  LostAndFound
//
//  Created by Daniel on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface DraggablePinAnnotation : NSObject<MKAnnotation> 

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;


@end
