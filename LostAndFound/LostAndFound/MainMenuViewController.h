//
//  MainMenuViewController.h
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011. All rights reserved.
//

/* APPLICATION DESCRIPTION:

 LocalLoser provides a central hub for lost & found exchanges. It gets you in touch with the kind strangers who have picked up your lost items, and who might not otherwise have a trail back to you. 
 
 LocalLoser is designed to prevent thieves from using the application as a means of claiming lost property. That is, it looks to ensure that losers have in fact lost the goods that they claim to have lost:
        1. Users must first post their lost item before viewing the database of lost items. This way, finders can then verify a match between the loser's posting and the item they have found, before they relinquish the property. 
        2. Lost Item postings ask for proof of ownership. 
 
 The application mocks a server-side database with CoreData. I have included some dummy data to demonstrate functionality. 
 
 Getting in contact with other LocalLoser users involves an MFMailComposeViewController. This (along with a few smaller things like draggable pin annotations or image compression) is the feature of my application not covered in class. 
*/

#import <UIKit/UIKit.h>
#import "UserInfoViewController.h"


@interface MainMenuViewController : UIViewController <UserInfoViewControllerDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil inContext:(NSManagedObjectContext *)aContext;

@end
