//
//  FoundItemViewController.m
//  LostAndFound
//
//  Created by Daniel Capo.
//  Copyright 2011. All rights reserved.
//

#import "FoundItemViewController.h"
#import "FoundItem.h"
#import "FoundItem_Create.h"
#import "DraggablePinAnnotation.h"
#import <MobileCoreServices/MobileCoreServices.h>


// Very similary to LostItemViewController. However, it does not contain the ownershipProof or reward textfields, 
// and gives the user the opportunity to take a picture of the found item. 

@interface FoundItemViewController() <MKMapViewDelegate, UIActionSheetDelegate>
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *featuresTextField; 
@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, retain) NSMutableDictionary *formInfo;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *mapSegmentedControl;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *foundItemPhotoButton;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) UIGestureRecognizer *tap;
@end

@implementation FoundItemViewController

@synthesize nameTextField, featuresTextField, currentTextField, tap;
@synthesize scrollView, context, formInfo, mapView, mapSegmentedControl, imageView, foundItemPhotoButton;

-(NSMutableDictionary *)formInfo {
    if (!formInfo) formInfo = [[NSMutableDictionary alloc] init];
    return formInfo;
}

-(UIGestureRecognizer *)tap {
    if (!tap) tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(dismissKeyboard)];
    return tap;
}

-(void)setup
{
    self.title = @"Found Item";
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
    }
}

#pragma mark - View lifecycle

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
    
    DraggablePinAnnotation *pinAnnotation = [[DraggablePinAnnotation alloc] initWithCoordinate: currentCoordinate];
    [self.mapView addAnnotation:pinAnnotation];
    [pinAnnotation release];
}

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

#pragma mark - Found Item Image Setting

-(void)setFoundImageUsingPickerSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    
    NSString *mediaType = (NSString *)kUTTypeImage;
    if ([[UIImagePickerController availableMediaTypesForSourceType:picker.sourceType] containsObject:mediaType]) {
        picker.mediaTypes = [NSArray arrayWithObject:mediaType];
        [self presentModalViewController:picker animated:YES];
    }
    [picker release];
}

#define SOURCE_CAMERA @"Camera"
#define SOURCE_LIBRARY @"Photo Library"
#define SOURCE_CHOOSER_TITLE @"Choose Found Item Image"
#define SOURCE_CHOOSER_CANCEL @"Cancel"
- (IBAction)setImageButtonPressed:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSString *cancelButtonTitle = SOURCE_CHOOSER_CANCEL;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:SOURCE_CHOOSER_TITLE
                                                                 delegate:self
                                                        cancelButtonTitle:cancelButtonTitle
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:SOURCE_CAMERA, SOURCE_LIBRARY, nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    } else {
        [self setFoundImageUsingPickerSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

// UIActionSheet delegate method
// depending on which button is pressed (currently "Camera" or "Photo Library")
//   brings up the appropriate UIImagePickerController

- (void)actionSheet:(UIActionSheet *)sender clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *source = [sender buttonTitleAtIndex:buttonIndex];
    if ([source isEqualToString:SOURCE_CAMERA]) {
        [self setFoundImageUsingPickerSourceType:UIImagePickerControllerSourceTypeCamera];
    } else if ([source isEqualToString:SOURCE_LIBRARY]) {
        [self setFoundImageUsingPickerSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

// UIImagePickerController delegate method
// grabs the image from the controller

- (void)imagePickerController:(UIImagePickerController *)sender didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSData *photoData = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerEditedImage]);
    [self.formInfo setObject:photoData forKey:@"photoData"];
    [self.foundItemPhotoButton setImage:[info objectForKey:UIImagePickerControllerEditedImage] forState:UIControlStateNormal];
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
- (IBAction)postFoundItemPressed:(UIButton *)sender 
{    
    [self.currentTextField resignFirstResponder];
    if ([self.nameTextField.text isEqualToString:@""]) {
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:self];
        [dialog setTitle:@"Uh Oh!"];
        [dialog setMessage:@"Item Name is required. Please supply it."];
        [dialog addButtonWithTitle:@"Okay"];
        [dialog show];
        [dialog release];
    } else {
        NSDictionary *userInformation = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        [self.formInfo setObject:[userInformation objectForKey:@"userName"] forKey:@"userName"];
        [self.formInfo setObject:[userInformation objectForKey:@"userCell"] forKey:@"userCell"];
        [self.formInfo setObject:[userInformation objectForKey:@"userEmail"] forKey:@"userEmail"];
        if (![self.formInfo objectForKey:@"photoData"]) [self.formInfo setObject: UIImagePNGRepresentation([UIImage imageNamed:@"no-photo.png"]) forKey: @"photoData"];
        CGSize size= CGSizeMake(THUMBNAIL_EDGE, THUMBNAIL_EDGE);
        NSData *thumbnailData = [self thumbnailOfSize:size fromData:[self.formInfo objectForKey:@"photoData"]];
        [self.formInfo setObject:thumbnailData forKey:@"thumbnailData"];

        NSString *identifier = [[self.formInfo objectForKey:@"userName"] stringByAppendingString:[self.formInfo objectForKey:@"name"]];
        [self.formInfo setObject:identifier forKey:@"identifier"];
        [FoundItem foundItemWithFormInfo:self.formInfo inManagedObjectContext:self.context];
        // Once we have added the new found item to the database, we must return to the tableview of lostItems
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nameTextField.delegate = self;
    self.featuresTextField.delegate = self;
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
    self.scrollView = nil;
    self.currentTextField = nil;
    self.mapSegmentedControl = nil;
    self.mapView = nil;
    self.imageView = nil;
    self.foundItemPhotoButton = nil;
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
    [scrollView release];
    [currentTextField release];
    [formInfo release];
    [mapView release];
    [mapSegmentedControl release];
    [foundItemPhotoButton release];
    if (tap) [tap release];
    [super dealloc];
}

@end
