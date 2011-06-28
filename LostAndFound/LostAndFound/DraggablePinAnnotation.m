//
//  DraggablePinAnnotation.m
//  LostAndFound
//
//  Created by Daniel on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DraggablePinAnnotation.h"

//custom Annotation class
@implementation DraggablePinAnnotation: NSObject

@synthesize title, coordinate, subtitle;

- (NSString *)subtitle {
	return nil;
}

- (NSString *)title {
	return nil;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) annotationCoordinate{
	coordinate = annotationCoordinate;
	return self;
}

@end
