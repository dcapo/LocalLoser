//
//  LostItemViewController.h
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>

@interface LostItemViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, assign) NSManagedObjectContext* context;
@property (nonatomic, retain) IBOutlet UITextField *rewardTextField;  
@end
