//
//  UserInfoViewController.h
//  LostAndFound
//
//  Created by Daniel on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserInfoViewController;

@protocol UserInfoViewControllerDelegate
- (void)userInfoViewController:(UserInfoViewController *)userInfoController gotForm:(NSMutableDictionary *)form;
@end


@interface UserInfoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (assign) id <UserInfoViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
