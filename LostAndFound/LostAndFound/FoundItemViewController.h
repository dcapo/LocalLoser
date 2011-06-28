//
//  FoundItemViewController.h
//  LostAndFound
//
//  Created by Daniel Capo.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>


@interface FoundItemViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
    
@property (nonatomic, assign) NSManagedObjectContext* context;

@end
