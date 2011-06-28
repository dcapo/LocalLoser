//
//  LostItemInfoPageViewController.m
//  LostAndFound
//
//  Created by Daniel on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LostItemInfoPageViewController.h"
#import "FoundItemsTableViewController.h"
#import <MessageUI/MessageUI.h>


// LostItemInfoPageViewController is created without a xib. It creates a scrollView of variable length, according to
// what the user has supplied in the lost item form. 
@interface LostItemInfoPageViewController() <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, retain) UIScrollView *scrollView;
@end

//Credit to BadPirate of stack overflow
@interface UILabel (VariableLineNumber)
- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth;
@end

@implementation UILabel (VariableLineNumber)

- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = UILineBreakModeWordWrap;
    self.numberOfLines = 0;
    [self sizeToFit];
}
@end

@implementation LostItemInfoPageViewController
@synthesize scrollView, lostItem, isMyItem, context;

- (UIScrollView *)scrollView
{
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        scrollView.backgroundColor = [UIColor whiteColor];
    }
    return scrollView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

// returns the lower bound of the subview closest to the bottom of the screen
-(CGFloat) getLowerBoundOfLowestSubview {
    CGFloat lowerBound = 0;
    CGFloat lowestSubViewHeight = 0;
    for (UIView *subView in self.scrollView.subviews) {
        if (subView.frame.origin.y > lowerBound) {
            lowerBound = subView.frame.origin.y;
            lowestSubViewHeight = subView.frame.size.height;
        }
    }
    return lowerBound + lowestSubViewHeight;
}

#define MAX_HEIGHT 200
#define HEADER_FONT_SIZE 24.0f
#define P_FONT_SIZE 17.0f
#define LABEL_MARGIN 10
#define PICTURE_EDGE 150
#define BUTTON_HEIGHT 40
#define BUTTON_WIDTH 175

-(void)loadUpScrollView {
    // Item Image 
    UIImageView *lostItemImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.lostItem.photoData]];
    lostItemImageView.frame = CGRectMake((self.scrollView.frame.size.width - PICTURE_EDGE)/2, LABEL_MARGIN, PICTURE_EDGE, PICTURE_EDGE);
    [self.scrollView addSubview:lostItemImageView];
    [lostItemImageView release];
    // Item Name
    UILabel *label = [[UILabel alloc] init];
    label.text = self.lostItem.name;
    label.font = [UIFont boldSystemFontOfSize:HEADER_FONT_SIZE];
    CGFloat labelWidth = self.scrollView.frame.size.width - (2*LABEL_MARGIN);
    [label sizeToFitFixedWidth:labelWidth];
    label.frame = CGRectMake((self.scrollView.frame.size.width - label.frame.size.width)/2, [self getLowerBoundOfLowestSubview] + LABEL_MARGIN, label.frame.size.width, label.frame.size.height);
    [label setBackgroundColor:self.scrollView.backgroundColor];
    label.textAlignment = UITextAlignmentCenter;
    [self.scrollView addSubview:label];
    [label release];
    
    // Item Features
    if (self.lostItem.features) {
        label = [[UILabel alloc] init];
        label.text = @"Item Description:";
        label.font = [UIFont boldSystemFontOfSize:P_FONT_SIZE];
        [label sizeToFitFixedWidth:labelWidth];
        label.frame = CGRectMake(LABEL_MARGIN, [self getLowerBoundOfLowestSubview] + LABEL_MARGIN, label.frame.size.width, label.frame.size.height);
        [label setBackgroundColor:self.scrollView.backgroundColor];
        [self.scrollView addSubview:label];
        [label release];
        
        label = [[UILabel alloc] init];
        label.text = self.lostItem.features;
        label.font = [UIFont systemFontOfSize:P_FONT_SIZE];
        [label sizeToFitFixedWidth:labelWidth];
        label.frame = CGRectMake(LABEL_MARGIN, [self getLowerBoundOfLowestSubview] + LABEL_MARGIN/4, label.frame.size.width, label.frame.size.height);
        [label setBackgroundColor:self.scrollView.backgroundColor];
        [self.scrollView addSubview:label];
        [label release];
    }
    
    // Ownership Proof
    if (self.lostItem.ownershipProof) {
        label = [[UILabel alloc] init];
        label.text = @"Proof Of Ownership:";
        label.font = [UIFont boldSystemFontOfSize:P_FONT_SIZE];
        [label sizeToFitFixedWidth:labelWidth];
        label.frame = CGRectMake(LABEL_MARGIN, [self getLowerBoundOfLowestSubview] + LABEL_MARGIN, label.frame.size.width, label.frame.size.height);
        [label setBackgroundColor:self.scrollView.backgroundColor];
        [self.scrollView addSubview:label];
        [label release];
        
        label = [[UILabel alloc] init];
        label.text = self.lostItem.ownershipProof;
        label.font = [UIFont systemFontOfSize:P_FONT_SIZE];
        [label sizeToFitFixedWidth:labelWidth];
        label.frame = CGRectMake(LABEL_MARGIN, [self getLowerBoundOfLowestSubview] + LABEL_MARGIN/4, label.frame.size.width, label.frame.size.height);
        [label setBackgroundColor:self.scrollView.backgroundColor];
        [self.scrollView addSubview:label];
        [label release];
    }
    
    // Reward
    if (self.lostItem.reward) {
        label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"Reward: %@", self.lostItem.reward];
        label.font = [UIFont boldSystemFontOfSize:P_FONT_SIZE];
        [label sizeToFitFixedWidth:labelWidth];
        label.frame = CGRectMake(LABEL_MARGIN, [self getLowerBoundOfLowestSubview] + LABEL_MARGIN, label.frame.size.width, label.frame.size.height);
        [label setBackgroundColor:self.scrollView.backgroundColor];
        [self.scrollView addSubview:label];
        [label release];
    }
    // the boolean isMyItem is used to change the buttons at the bottom of the screen, depending on whether or not
    // we have just come from a MyLostItemsTableViewController or not. If the former, we want to give the user the
    // option of deleting a recovered item from the database, and also exploring found items nearby (again). 
    if (isMyItem) {
        UIButton *deleteThisItem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [deleteThisItem setTitle:@"I Recovered This" forState:UIControlStateNormal];
        [deleteThisItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deleteThisItem.frame = CGRectMake((self.scrollView.frame.size.width - BUTTON_WIDTH)/2, 
                                                [self getLowerBoundOfLowestSubview] + 2*LABEL_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
        [deleteThisItem setBackgroundImage:[UIImage imageNamed:@"button_blue.png"] forState:UIControlStateNormal];
        [deleteThisItem addTarget:self action:@selector(deleteItem) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:deleteThisItem];
        
        UIButton *viewNearbyItems = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [viewNearbyItems setTitle:@"View Nearby Items" forState:UIControlStateNormal];
        [viewNearbyItems setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        viewNearbyItems.frame = CGRectMake((self.scrollView.frame.size.width - BUTTON_WIDTH)/2, 
                                                [self getLowerBoundOfLowestSubview] + 2*LABEL_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
        [viewNearbyItems setBackgroundImage:[UIImage imageNamed:@"button_lightBlue.png"] forState:UIControlStateNormal];
        [viewNearbyItems addTarget:self action:@selector(viewNearbyItems) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:viewNearbyItems];
    }
    else {
        UIButton *iFoundThisItemButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [iFoundThisItemButton setTitle:@"I Found This Item!" forState:UIControlStateNormal];
        [iFoundThisItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        iFoundThisItemButton.frame = CGRectMake((self.scrollView.frame.size.width - BUTTON_WIDTH)/2, 
                                                [self getLowerBoundOfLowestSubview] + 2*LABEL_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
        [iFoundThisItemButton setBackgroundImage:[UIImage imageNamed:@"button_blue.png"] forState:UIControlStateNormal];
        [iFoundThisItemButton addTarget:self action:@selector(itemFoundButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:iFoundThisItemButton];
    }
    
}

#define CONTACT_Q @"Contact the Loser Via:"
#define CANCEL_TITLE @"Cancel"
#define PHONE_TITLE @"Phone"
#define EMAIL_TITLE @"Email"

// remove a lost item from the database
-(void)deleteItem {
    [context deleteObject:self.lostItem];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewNearbyItems {
    FoundItemsTableViewController *fitvc = [[FoundItemsTableViewController alloc] initInManagedObjectContext:self.context];
    fitvc.itemLatitude = [self.lostItem.locationLat doubleValue];
    fitvc.itemLongitude = [self.lostItem.locationLon doubleValue];
    [self.navigationController pushViewController:fitvc animated:YES];
    [fitvc release];
}

// present an action sheet which gives the user the option of calling/emailing the finder
-(void)itemFoundButtonClicked {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:CONTACT_Q
                                                             delegate:self
                                                    cancelButtonTitle:CANCEL_TITLE
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:PHONE_TITLE, EMAIL_TITLE, nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}

- (void)actionSheet:(UIActionSheet *)sender clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *source = [sender buttonTitleAtIndex:buttonIndex];
    // Call the finder
    if ([source isEqualToString:PHONE_TITLE]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.lostItem.userCell]]];
    } else if ([source isEqualToString:EMAIL_TITLE]) {
        //Load an email with auto-data
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:[NSArray arrayWithObject:self.lostItem.userEmail]];
        NSString *messageBody = [NSString stringWithFormat: 
                                 @"Dear %@,\r This message is from a fellow user on LocalLoser. I have found your item by the name: %@! To acquire it, reply to this email so we can make arrangements. Or, you can reach me at %@.\r", 
                                 self.lostItem.userName, self.lostItem.name, [[[NSUserDefaults standardUserDefaults] objectForKey:@"userInformation"] objectForKey:@"userCell"]];
        [controller setSubject:@"LocalLoser Item Found!"];
        [controller setMessageBody:messageBody isHTML:NO]; 
        if (controller) [self presentModalViewController:controller animated:YES];
        [controller release];
    }
}

// mail delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissModalViewControllerAnimated:YES];
}

// returns a view that subsumes all of the scrollview's subviews
- (CGSize)contentSizeForScrollView
{
    CGRect biggestRect = CGRectNull;
    BOOL firstIteration = YES;
    //minx and minY are the margins
    CGFloat minX, minY;
    for (UIView *subview in self.scrollView.subviews) {
        if (firstIteration) {
            minX = subview.frame.origin.x;
            minY = subview.frame.origin.y;
            firstIteration = NO;
        } else {
            if (subview.frame.origin.x < minX) minX = subview.frame.origin.x; 
            if (subview.frame.origin.y < minY) minY = subview.frame.origin.y;
        }  
        //keep building up the size of biggestRect, which will contain all the subviews
        biggestRect = CGRectUnion(biggestRect, subview.frame);
    }
    return CGSizeMake(biggestRect.size.width + 2*minX, biggestRect.size.height + 2*minY);
}

- (void)loadView
{
    self.title = @"Lost Item";
    self.scrollView.delegate = self;
    self.view = self.scrollView; 
    [self.scrollView setBackgroundColor:[UIColor colorWithRed:220/255.0 green:229/255.0 blue:246/255.0 alpha:1]];
    [self loadUpScrollView];
    self.scrollView.contentSize = [self contentSizeForScrollView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.scrollView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [scrollView release];
    [context release];
    [lostItem release];
    [super dealloc];
}

@end