//
//  LostItemViewController.m
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011. All rights reserved.
//

// LostItemViewController is a form that users must fill out to post their lost items. It features
// a MapView, on which users drag a pin to the point where they had their item last, an "Image Select"
// button, and textFields for item name, description, reward, etc. 

#import "LostItemViewController.h"
#import "LostItem.h"
#import "LostItem_Create.h"
#import "DraggablePinAnnotation.h"
#import "FoundItemsTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface LostItemViewController() <MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *featuresTextField;
@property (nonatomic, retain) IBOutlet UITextField *proofTextField;  
@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, retain) NSMutableDictionary *formInfo;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *mapSegmentedControl;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *lostItemPhotoButton;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) UIGestureRecognizer *tap;
@end

@implementation LostItemViewController

@synthesize nameTextField, featuresTextField, proofTextField, currentTextField, rewardTextField;
@synthesize scrollView, context, formInfo, mapView, mapSegmentedControl, imageView, lostItemPhotoButton;
@synthesize  tap;

-(UIGestureRecognizer *)tap {
    if (!tap) tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(dismissKeyboard)];
    return tap;
}

-(NSMutableDictionary *)formInfo {
    if (!formInfo) formInfo = [[NSMutableDictionary alloc] init];
    return formInfo;
}

-(void)setup
{
    self.title = @"Lost Item";
}

-(void)awakeFromNib {
    [self setup];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //Do not allow user to resign the textField when it is empty. 
    if (textField.text.length) {
        [textField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        if (textField == self.nameTextField) [self.formInfo setObject:textField.text forKey:@"name"]; 
        else if (textField == self.featuresTextField) [self.formInfo setObject:textField.text forKey:@"features"];
        else if (textField == self.proofTextField) [self.formInfo setObject:textField.text forKey:@"ownershipProof"];
        else if (textField == self.rewardTextField) [self.formInfo setObject:textField.text forKey:@"reward"];
    }
}

#pragma mark - View lifecycle

//Move the scrollview to display the current textfield, if necessary
-(void)theKeyboardAppeared: (NSNotification *)notification
{
    NSValue* keyboardFrameValue = [[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [keyboardFrameValue CGRectValue].size;
    
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height -= keyboardSize.height;
    self.scrollView.frame = viewFrame;
    
    CGRect textFieldRect = [self.currentTextField frame];
    textFieldRect.origin.y += (3*textFieldRect.size.height);    
    [self.scrollView scrollRectToVisible:textFieldRect animated:YES];
    
    [self.view addGestureRecognizer:self.tap];
}

-(void)theKeyboardDisappeared: (NSNotification *)notification 
{
    NSValue* keyboardFrameValue = [[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [keyboardFrameValue CGRectValue].size;
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height += keyboardSize.height;
    self.scrollView.frame = viewFrame;
    
    [self.view removeGestureRecognizer:self.tap];
}

-(void)dismissKeyboard {
    [self.currentTextField resignFirstResponder];
}

// This button switches between standard, satellite, and hybrid map types. 
- (IBAction)changeMapType:(UISegmentedControl *)sender 
{
    if(self.mapSegmentedControl.selectedSegmentIndex==0){
        mapView.mapType=MKMapTypeStandard;
    }
    else if (self.mapSegmentedControl.selectedSegmentIndex==1){
        mapView.mapType=MKMapTypeSatellite;
    }
    else if (self.mapSegmentedControl.selectedSegmentIndex==2){
        mapView.mapType=MKMapTypeHybrid;
    }
}

//set InitialMap moves the map to the user's current location. 
#define SEARCH_RADIUS 0.01
-(void)setInitialMap 
{
    CLLocationCoordinate2D currentCoordinate;
    currentCoordinate.latitude = self.mapView.userLocation.location.coordinate.latitude;
    currentCoordinate.longitude = self.mapView.userLocation.location.coordinate.longitude;
    [self.formInfo setObject:[NSNumber numberWithDouble:currentCoordinate.latitude] forKey:@"locationLat"];
    [self.formInfo setObject:[NSNumber numberWithDouble:currentCoordinate.longitude] forKey:@"locationLon"];
    MKCoordinateRegion initialRegion;
    MKCoordinateSpan initialMapSpan;
    initialMapSpan.latitudeDelta = SEARCH_RADIUS;
    initialMapSpan.longitudeDelta = SEARCH_RADIUS;
    initialRegion.span = initialMapSpan;
    initialRegion.center = currentCoordinate;
    
    [self.mapView setRegion:initialRegion animated:NO];
    
    // Drop a single pin at the user's current location. This will be dragged to wherever the user thinks he/she lost
    // the item. 
    DraggablePinAnnotation *pinAnnotation = [[DraggablePinAnnotation alloc] initWithCoordinate: currentCoordinate];
    [self.mapView addAnnotation:pinAnnotation];
    [pinAnnotation release];
}

// watch for the first update to user's location. Once it exists, we know we can set the initial map. 
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setInitialMap];
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
}

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == self.mapView.userLocation) return nil;
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:@"MK"];
    if (!aView) {
        aView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MK"] autorelease];
        aView.draggable = YES;
    }
    aView.annotation = annotation;
    return aView;
}

// Delegate method called whenever the users starts or stops dragging a pin
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
    if (newState == MKAnnotationViewDragStateEnding) {
        DraggablePinAnnotation *annotation = annotationView.annotation;
        [self.formInfo setObject:[NSNumber numberWithDouble:annotation.coordinate.latitude] forKey:@"locationLat"];
        [self.formInfo setObject:[NSNumber numberWithDouble:annotation.coordinate.longitude] forKey:@"locationLon"];
        NSLog(@"New Coordinate Set: %f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude);
    }
}

- (void)mapView:(MKMapView *)sender didSelectAnnotationView:(MKAnnotationView *)aView
{
    if (aView.annotation == self.mapView.userLocation) aView.canShowCallout = NO;
}

#pragma mark - Lost Item Image Setting

// The camera is not necessary here because we assume the user will have no item to take a picture of!
- (IBAction)setImageButtonPressed:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    
    NSString *mediaType = (NSString *)kUTTypeImage;
    if ([[UIImagePickerController availableMediaTypesForSourceType:picker.sourceType] containsObject:mediaType]) {
        picker.mediaTypes = [NSArray arrayWithObject:mediaType];
        [self presentModalViewController:picker animated:YES];
    }
    [picker release];
}

// UIImagePickerController delegate method
// grabs the image from the controller

- (void)imagePickerController:(UIImagePickerController *)sender didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSData *photoData = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerEditedImage]);
    [self.formInfo setObject:photoData forKey:@"photoData"];
    [self.lostItemPhotoButton setImage:[info objectForKey:UIImagePickerControllerEditedImage] forState:UIControlStateNormal];
    [self dismissModalViewControllerAnimated:YES];
}

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

#define USER_INFO @"userInformation"
#define THUMBNAIL_EDGE 75
- (IBAction)postLostItemPressed:(UIButton *)sender 
{    
    [self.currentTextField resignFirstResponder];
    // Make sure at least the item name is supplied
    if ([self.nameTextField.text isEqualToString:@""]) {
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:self];
        [dialog setTitle:@"Uh Oh!"];
        [dialog setMessage:@"Item Name is required. Please supply it."];
        [dialog addButtonWithTitle:@"Okay"];
        [dialog show];
        [dialog release];
    } else {
        //Load up the formInfo dictionary, which is, in turn, passed to Core Data
        NSDictionary *userInformation = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        [self.formInfo setObject:[userInformation objectForKey:@"userName"] forKey:@"userName"];
        [self.formInfo setObject:[userInformation objectForKey:@"userCell"] forKey:@"userCell"];
        [self.formInfo setObject:[userInformation objectForKey:@"userEmail"] forKey:@"userEmail"];
        if (![self.formInfo objectForKey:@"photoData"]) [self.formInfo setObject: UIImagePNGRepresentation([UIImage imageNamed:@"no-photo.png"]) 
                                                                          forKey: @"photoData"];
        CGSize size= CGSizeMake(THUMBNAIL_EDGE, THUMBNAIL_EDGE);
        NSData *thumbnailData = [self thumbnailOfSize:size fromData:[self.formInfo objectForKey:@"photoData"]];
        [self.formInfo setObject:thumbnailData forKey:@"thumbnailData"];
        NSString *identifier = [[self.formInfo objectForKey:@"userName"] stringByAppendingString:[self.formInfo objectForKey:@"name"]];
        [self.formInfo setObject:identifier forKey:@"identifier"];
        //Add a new Lost Item
        [LostItem lostItemWithFormInfo:self.formInfo inManagedObjectContext:self.context];
        //Here we direct the user to a list of nearby found items, to see if there is a match
        FoundItemsTableViewController *fitvc = [[FoundItemsTableViewController alloc] initInManagedObjectContext:self.context];
        fitvc.itemLatitude = [[self.formInfo objectForKey:@"locationLat"] doubleValue];
        fitvc.itemLongitude = [[self.formInfo objectForKey:@"locationLon"] doubleValue];
        [self.navigationController pushViewController:fitvc animated:YES];
        [fitvc release];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nameTextField.delegate = self;
    self.featuresTextField.delegate = self;
    self.proofTextField.delegate = self;
    self.rewardTextField.delegate = self;
    self.mapView.delegate = self;
    self.scrollView.delegate = self;
    self.mapView.showsUserLocation = TRUE;
    self.mapView.mapType = MKMapTypeStandard;
    self.scrollView.contentSize = self.scrollView.frame.size;
    self.scrollView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, 
                                       [[UIScreen mainScreen] applicationFrame].size.height);     
    [self.mapView.userLocation addObserver:self forKeyPath:@"location" 
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.nameTextField = nil;
    self.featuresTextField = nil;
    self.proofTextField = nil;
    self.scrollView = nil;
    self.currentTextField = nil;
    self.mapSegmentedControl = nil;
    self.mapView = nil;
    self.imageView = nil;
    self.lostItemPhotoButton = nil;
    self.rewardTextField = nil;
}

-(void)viewWillAppear:(BOOL)animated { 
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theKeyboardAppeared:)
                                                 name:UIKeyboardDidShowNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theKeyboardDisappeared:) 
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [self.scrollView flashScrollIndicators];
    [super viewDidAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [nameTextField release];
    [featuresTextField release];
    [proofTextField release];
    [rewardTextField release];
    [scrollView release];
    [currentTextField release];
    [formInfo release];
    [mapView release];
    [mapSegmentedControl release];
    [lostItemPhotoButton release];  
    [super dealloc];
}

@end
