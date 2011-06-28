//
//  MainMenuViewController.m
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011. All rights reserved.
//

#import "MainMenuViewController.h"
#import "UserInfoViewController.h"
#import "LostItemViewController.h"
#import "FoundItemViewController.h"
#import "LostItemsTableViewController.h"
#import "MyLostItemsTableViewController.h"
#import "FoundItemsTableViewController.h"
#import "LostItem.h"
#import "LostItem_Create.h"
#import "FoundItem.h"
#import "FoundItem_Create.h"

@interface MainMenuViewController()
@property (nonatomic, assign) NSManagedObjectContext *context;
@end

@implementation MainMenuViewController

@synthesize context;

//Runs the first time the application is opened
-(void) acquireUserInfo {
    UserInfoViewController *userInfoController = [[UserInfoViewController alloc] initWithNibName:nil bundle:nil];
    userInfoController.delegate = self;
    userInfoController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:userInfoController animated:YES];
    [userInfoController release];
}

//create a thumbnail to display in tableViews:
- (NSData *)thumbnailOfSize:(CGSize)size fromData:(NSData *)photoData {
    
    UIGraphicsBeginImageContext(size);
    UIImage *photo = [UIImage imageWithData:photoData];
    // draw scaled image into thumbnail context
    [photo drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();        
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil) 
        NSLog(@"could not scale image");
    return UIImagePNGRepresentation(newThumbnail);
}

//DUMMY DATA: includes both sample lost and found items
#define THUMBNAIL_SIZE 75
-(void)loadSampleData {
    NSMutableDictionary *sample = [[NSMutableDictionary alloc] init];
    [sample setObject:@"Ravneet" forKey:@"userName"];
    [sample setObject:@"ravneet@stanford.edu" forKey:@"userEmail"];
    [sample setObject:@"6508624751" forKey:@"userCell"];
    [sample setObject:@"My cat, Jenkins" forKey:@"name"];
    [sample setObject:@"Collar with silver tag" forKey:@"features"];
    [sample setObject:@"Tag reads: Jenkins, 2/9/2008" forKey:@"ownershipProof"];
    [sample setObject:@"$100" forKey:@"reward"];
    NSData  *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"cat.jpg"], 0.8);
    [sample setObject:imageData forKey:@"photoData"];
    [sample setObject:[self thumbnailOfSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) fromData:imageData] forKey:@"thumbnailData"];
    NSString *identifier = [[sample objectForKey:@"userName"] stringByAppendingString:[sample objectForKey:@"name"]];
    [sample setObject:identifier forKey:@"identifier"];
    double latitude = 37.427451;
    double longtitude = -122.170329;
    [sample setObject:[NSNumber numberWithDouble:latitude] forKey:@"locationLat"];
    [sample setObject:[NSNumber numberWithDouble:longtitude] forKey:@"locationLon"];
    [LostItem lostItemWithFormInfo:sample inManagedObjectContext:self.context];
    [sample release];
    
    sample = [[NSMutableDictionary alloc] init];
    [sample setObject:@"Emma" forKey:@"userName"];
    [sample setObject:@"ekventurini@gmail.com" forKey:@"userEmail"];
    [sample setObject:@"9146565569" forKey:@"userCell"];
    [sample setObject:@"Tennis Racket" forKey:@"name"];
    [sample setObject:@"Head Liquidmetal Racket, orange and silver" forKey:@"features"];
    [sample setObject:@"White grip; Handle cap is gone" forKey:@"ownershipProof"];
    [sample setObject:@"$30" forKey:@"reward"];
    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"tennis_racket.jpg"], 0.8);
    [sample setObject:imageData forKey:@"photoData"];
    [sample setObject:[self thumbnailOfSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) fromData:imageData] forKey:@"thumbnailData"];
    identifier = [[sample objectForKey:@"userName"] stringByAppendingString:[sample objectForKey:@"name"]];
    [sample setObject:identifier forKey:@"identifier"];
    latitude = 37.424676;
    longtitude = -122.169226;
    [sample setObject:[NSNumber numberWithDouble:latitude] forKey:@"locationLat"];
    [sample setObject:[NSNumber numberWithDouble:longtitude] forKey:@"locationLon"];
    [LostItem lostItemWithFormInfo:sample inManagedObjectContext:self.context];
    [sample release];
    
    sample = [[NSMutableDictionary alloc] init];
    [sample setObject:@"Scotty Smalls" forKey:@"userName"];
    [sample setObject:@"danielccapo@gmail.com" forKey:@"userEmail"];
    [sample setObject:@"9146565569" forKey:@"userCell"];
    [sample setObject:@"Babe Ruth Autographed Baseball" forKey:@"name"];
    [sample setObject:@"Ball has bite marks; saliva stains. I hit it over a fence the other day and the beast got to it. At the time, I didn't know who Babe Ruth was, or that the autographed ball had immense value. " forKey:@"features"];
    [sample setObject:@"Signature is in blue ink" forKey:@"ownershipProof"];
    [sample setObject:@"$4" forKey:@"reward"];
    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"baseball.jpg"], 0.8);
    [sample setObject:imageData forKey:@"photoData"];
    [sample setObject:[self thumbnailOfSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) fromData:imageData] forKey:@"thumbnailData"];
    identifier = [[sample objectForKey:@"userName"] stringByAppendingString:[sample objectForKey:@"name"]];
    [sample setObject:identifier forKey:@"identifier"];
    latitude = 37.426461;
    longtitude = -122.170026;
    [sample setObject:[NSNumber numberWithDouble:latitude] forKey:@"locationLat"];
    [sample setObject:[NSNumber numberWithDouble:longtitude] forKey:@"locationLon"];
    [LostItem lostItemWithFormInfo:sample inManagedObjectContext:self.context];
    [sample release];
    
    sample = [[NSMutableDictionary alloc] init];
    [sample setObject:@"Sonny Corleone" forKey:@"userName"];
    [sample setObject:@"danielccapo@gmail.com" forKey:@"userEmail"];
    [sample setObject:@"9146565569" forKey:@"userCell"];
    [sample setObject:@"Switchblade" forKey:@"name"];
    [sample setObject:@"black handle" forKey:@"features"];
    [sample setObject:@"I'll show you some freakin' proof." forKey:@"ownershipProof"];
    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"switchblade.jpg"], 0.8);
    [sample setObject:imageData forKey:@"photoData"];
    [sample setObject:[self thumbnailOfSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) fromData:imageData] forKey:@"thumbnailData"];
    identifier = [[sample objectForKey:@"userName"] stringByAppendingString:[sample objectForKey:@"name"]];
    [sample setObject:identifier forKey:@"identifier"];
    latitude = 37.411269;
    longtitude = -122.161237;
    [sample setObject:[NSNumber numberWithDouble:latitude] forKey:@"locationLat"];
    [sample setObject:[NSNumber numberWithDouble:longtitude] forKey:@"locationLon"];
    [LostItem lostItemWithFormInfo:sample inManagedObjectContext:self.context];
    [sample release];
    
    sample = [[NSMutableDictionary alloc] init];
    [sample setObject:@"Best Man" forKey:@"userName"];
    [sample setObject:@"danielccapo@gmail.com" forKey:@"userEmail"];
    [sample setObject:@"9146565569" forKey:@"userCell"];
    [sample setObject:@"Wedding Ring" forKey:@"name"];
    [sample setObject:@"14 carat diamond" forKey:@"features"];
    [sample setObject:@"$4000" forKey:@"reward"];
    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"wedding_ring2.jpg"], 0.8);
    [sample setObject:imageData forKey:@"photoData"];
    [sample setObject:[self thumbnailOfSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) fromData:imageData] forKey:@"thumbnailData"];
    identifier = [[sample objectForKey:@"userName"] stringByAppendingString:[sample objectForKey:@"name"]];
    [sample setObject:identifier forKey:@"identifier"];
    latitude = 37.388032;
    longtitude = -122.154093;
    [sample setObject:[NSNumber numberWithDouble:latitude] forKey:@"locationLat"];
    [sample setObject:[NSNumber numberWithDouble:longtitude] forKey:@"locationLon"];
    [LostItem lostItemWithFormInfo:sample inManagedObjectContext:self.context];
    [sample release];
    
    sample = [[NSMutableDictionary alloc] init];
    [sample setObject:@"Jason" forKey:@"userName"];
    [sample setObject:@"danielccapo@gmail.com" forKey:@"userEmail"];
    [sample setObject:@"9146565569" forKey:@"userCell"];
    [sample setObject:@"Steinway Grand Piano" forKey:@"name"];
    [sample setObject:@"Black with ivory keys" forKey:@"features"];
    [sample setObject:@"Lowest A flat does not work" forKey:@"ownershipProof"];
    [sample setObject:@"$4" forKey:@"reward"];
    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"piano.jpg"], 0.8);
    [sample setObject:imageData forKey:@"photoData"];
    [sample setObject:[self thumbnailOfSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) fromData:imageData] forKey:@"thumbnailData"];
    identifier = [[sample objectForKey:@"userName"] stringByAppendingString:[sample objectForKey:@"name"]];
    [sample setObject:identifier forKey:@"identifier"];
    latitude = 37.357294;
    longtitude = -122.223363;
    [sample setObject:[NSNumber numberWithDouble:latitude] forKey:@"locationLat"];
    [sample setObject:[NSNumber numberWithDouble:longtitude] forKey:@"locationLon"];
    [LostItem lostItemWithFormInfo:sample inManagedObjectContext:self.context];
    [sample release];
    
    sample = [[NSMutableDictionary alloc] init];
    [sample setObject:@"Steve" forKey:@"userName"];
    [sample setObject:@"danielccapo@gmail.com" forKey:@"userEmail"];
    [sample setObject:@"9146565569" forKey:@"userCell"];
    [sample setObject:@"Ray Ban Sunglasses" forKey:@"name"];
    [sample setObject:@"Black trim" forKey:@"features"];
    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"sunglasses.jpg"], 0.8);
    [sample setObject:imageData forKey:@"photoData"];
    [sample setObject:[self thumbnailOfSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) fromData:imageData] forKey:@"thumbnailData"];
    identifier = [[sample objectForKey:@"userName"] stringByAppendingString:[sample objectForKey:@"name"]];
    [sample setObject:identifier forKey:@"identifier"];
    latitude = 37.425192;
    longtitude = -122.167470;
    [sample setObject:[NSNumber numberWithDouble:latitude] forKey:@"locationLat"];
    [sample setObject:[NSNumber numberWithDouble:longtitude] forKey:@"locationLon"];
    [FoundItem foundItemWithFormInfo:sample inManagedObjectContext:self.context];
    [sample release];
    
    sample = [[NSMutableDictionary alloc] init];
    [sample setObject:@"Steve" forKey:@"userName"];
    [sample setObject:@"danielccapo@gmail.com" forKey:@"userEmail"];
    [sample setObject:@"9146565569" forKey:@"userCell"];
    [sample setObject:@"Black fedora" forKey:@"name"];
    [sample setObject:@"Checkered ribbon" forKey:@"features"];
    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"fedora.jpg"], 0.8);
    [sample setObject:imageData forKey:@"photoData"];
    [sample setObject:[self thumbnailOfSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) fromData:imageData] forKey:@"thumbnailData"];
    identifier = [[sample objectForKey:@"userName"] stringByAppendingString:[sample objectForKey:@"name"]];
    [sample setObject:identifier forKey:@"identifier"];
    latitude = 37.427188;
    longtitude = -122.168114;
    [sample setObject:[NSNumber numberWithDouble:latitude] forKey:@"locationLat"];
    [sample setObject:[NSNumber numberWithDouble:longtitude] forKey:@"locationLon"];
    [FoundItem foundItemWithFormInfo:sample inManagedObjectContext:self.context];
    [sample release];
    
    sample = [[NSMutableDictionary alloc] init];
    [sample setObject:@"Linda" forKey:@"userName"];
    [sample setObject:@"danielccapo@gmail.com" forKey:@"userEmail"];
    [sample setObject:@"19146565569" forKey:@"userCell"];
    [sample setObject:@"Car Keys" forKey:@"name"];
    [sample setObject:@"Flashlight keychain" forKey:@"features"];
    imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"carKeys.jpg"], 0.8);
    [sample setObject:imageData forKey:@"photoData"];
    [sample setObject:[self thumbnailOfSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) fromData:imageData] forKey:@"thumbnailData"];
    identifier = [[sample objectForKey:@"userName"] stringByAppendingString:[sample objectForKey:@"name"]];
    [sample setObject:identifier forKey:@"identifier"];
    latitude = 37.340397;
    longtitude = -122.108445;
    [sample setObject:[NSNumber numberWithDouble:latitude] forKey:@"locationLat"];
    [sample setObject:[NSNumber numberWithDouble:longtitude] forKey:@"locationLon"];
    [FoundItem foundItemWithFormInfo:sample inManagedObjectContext:self.context];
    [sample release];
}


#define USER_INFO @"userInformation"
-(void)setup
{
    self.title = @"Lost and Found";
}

-(void)awakeFromNib {
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil inContext:(NSManagedObjectContext *)aContext
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.context = aContext;
        [self setup];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO]) [self loadSampleData];
    }
    return self;
}

// Delegate method for modal view controller
- (void)userInfoViewController:(UserInfoViewController *)userInfoController gotForm:(NSMutableDictionary *)form {
    [[NSUserDefaults standardUserDefaults] setObject:form forKey:USER_INFO];
    NSLog(@"%@", [form description]);
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)lostButtonPressed:(UIButton *)sender {
    LostItemViewController *lostItemController = [[LostItemViewController alloc] init];
    lostItemController.context = self.context;
    [self.navigationController pushViewController:lostItemController animated:YES];
    [lostItemController release];
}

// The idea here is that users should check the database of nearby lost items before posting a found item. The matching lost item could exist, in which case the user could contact the loser directly and avoid unnecessarily filling out a form. 
- (IBAction)foundButtonPressed:(UIButton *)sender {
    LostItemsTableViewController *litvc = [[LostItemsTableViewController alloc] initInManagedObjectContext:self.context];
    [self.navigationController pushViewController:litvc animated:YES];
    [litvc release];
}

- (IBAction)myContactInfoButtonPressed:(UIButton *)sender {
    [self acquireUserInfo];
}

- (IBAction)myLostItemsButtonPressed:(UIButton *)sender {
    MyLostItemsTableViewController *mlitvc = [[MyLostItemsTableViewController alloc] initInManagedObjectContext:self.context];
    [self.navigationController pushViewController:mlitvc animated:YES];
    [mlitvc release];
}


-(void) viewDidLoad 
{
    [super viewDidLoad];
    NSMutableDictionary *userInformation = [[NSUserDefaults standardUserDefaults ]objectForKey:USER_INFO];
    if (!userInformation) [self acquireUserInfo];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [super dealloc];
}

@end
