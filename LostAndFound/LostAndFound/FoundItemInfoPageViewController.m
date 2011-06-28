//
//  FoundItemInfoPageViewController.m
//  FoundAndFound
//
//  Created by Daniel. 
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// This class is essentially just the inverse of LostItemInfoPageViewController. 

#import "FoundItemInfoPageViewController.h"
#import <MessageUI/MessageUI.h>

@interface FoundItemInfoPageViewController() <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, retain) UIScrollView *scrollView;
@end

//Credit to BadPirate of stack overflow for this category
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

@implementation FoundItemInfoPageViewController
@synthesize scrollView, foundItem, context;;

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
    UIImageView *foundItemImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.foundItem.photoData]];
    foundItemImageView.frame = CGRectMake((self.scrollView.frame.size.width - PICTURE_EDGE)/2, LABEL_MARGIN, PICTURE_EDGE, PICTURE_EDGE);
    [self.scrollView addSubview:foundItemImageView];
    [foundItemImageView release];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = self.foundItem.name;
    label.font = [UIFont boldSystemFontOfSize:HEADER_FONT_SIZE];
    CGFloat labelWidth = self.scrollView.frame.size.width - (2*LABEL_MARGIN);
    [label sizeToFitFixedWidth:labelWidth];
    label.frame = CGRectMake((self.scrollView.frame.size.width - label.frame.size.width)/2, [self getLowerBoundOfLowestSubview] + LABEL_MARGIN, label.frame.size.width, label.frame.size.height);
    [label setBackgroundColor:self.scrollView.backgroundColor];
    label.textAlignment = UITextAlignmentCenter;
    [self.scrollView addSubview:label];
    [label release];
    
    if (self.foundItem.features) {
        label = [[UILabel alloc] init];
        label.text = @"Item Description:";
        label.font = [UIFont boldSystemFontOfSize:P_FONT_SIZE];
        [label sizeToFitFixedWidth:labelWidth];
        label.frame = CGRectMake(LABEL_MARGIN, [self getLowerBoundOfLowestSubview] + LABEL_MARGIN, label.frame.size.width, label.frame.size.height);
        [label setBackgroundColor:self.scrollView.backgroundColor];
        [self.scrollView addSubview:label];
        [label release];
        
        label = [[UILabel alloc] init];
        label.text = self.foundItem.features;
        label.font = [UIFont systemFontOfSize:P_FONT_SIZE];
        [label sizeToFitFixedWidth:labelWidth];
        label.frame = CGRectMake(LABEL_MARGIN, [self getLowerBoundOfLowestSubview] + LABEL_MARGIN/4, label.frame.size.width, label.frame.size.height);
        [label setBackgroundColor:self.scrollView.backgroundColor];
        [self.scrollView addSubview:label];
        [label release];
    }
    
    UIButton *iLostThisItemButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [iLostThisItemButton setTitle:@"I Lost This Item!" forState:UIControlStateNormal];
    [iLostThisItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    iLostThisItemButton.frame = CGRectMake((self.scrollView.frame.size.width - BUTTON_WIDTH)/2, 
                                            [self getLowerBoundOfLowestSubview] + 2*LABEL_MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT);
    [iLostThisItemButton setBackgroundImage:[UIImage imageNamed:@"button_blue.png"] forState:UIControlStateNormal];
    [iLostThisItemButton addTarget:self action:@selector(itemLostButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:iLostThisItemButton];
    
}

#define CONTACT_Q @"Contact the Loser Via:"
#define CANCEL_TITLE @"Cancel"
#define PHONE_TITLE @"Phone"
#define EMAIL_TITLE @"Email"

-(void)itemLostButtonClicked {
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
    if ([source isEqualToString:PHONE_TITLE]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.foundItem.userCell]]];
        [self.context deleteObject:self.foundItem];
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([source isEqualToString:EMAIL_TITLE]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:[NSArray arrayWithObject:self.foundItem.userEmail]];
        NSString *messageBody = [NSString stringWithFormat: 
                                 @"Dear %@,\n This message is from a fellow user on LocalLoser. I recently lost an item by the name, '%@,' and you found it! Please tell me how I can retrieve it.\nYou can also reach me at %@.\n", 
                                 self.foundItem.userName, self.foundItem.name, [[[NSUserDefaults standardUserDefaults] objectForKey:@"userInformation"] objectForKey:@"userCell"]];
        [controller setSubject:@"LocalLoser Message: You found my item!"];
        [controller setMessageBody:messageBody isHTML:NO]; 
        if (controller) [self presentModalViewController:controller animated:YES];
        [controller release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
        [self.context deleteObject:self.foundItem];
    }
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

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
    self.title = @"Found Item";
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
    [foundItem release];
    [context release];
    [super dealloc];
}

@end