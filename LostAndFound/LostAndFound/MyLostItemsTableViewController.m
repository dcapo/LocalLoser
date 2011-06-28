//
//  LostItemsTableViewController.m
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyLostItemsTableViewController.h"
#import "LostItem.h"
#import "LostItem_Create.h"
#import <MapKit/MapKit.h>
#import "LostItemInfoPageViewController.h"
#import "FoundItemViewController.h"

// MyLostItemsTableViewController is very similar to LostItemsTableViewController. It just has a different
// predicate, and also pushes display item info pages with different functionalities.  

@interface MyLostItemsTableViewController() <MKMapViewDelegate>
@property (retain) UITableView *tableView;
@property (nonatomic, retain) MKMapView *mapView;
@end

@implementation MyLostItemsTableViewController

@synthesize tableView, mapView, itemLatitude, itemLongitude;

- (MKMapView *)mapView
{
    if (!mapView) {
        mapView = [[MKMapView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return mapView;
}

#pragma mark - Designated Initializer

-(NSFetchedResultsController *) getFetchedResultsControllerInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"LostItem"
                                      inManagedObjectContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"userName = %@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"userInformation"] objectForKey:@"userName"]];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:
                                    [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:context
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];
    [fetchRequest release];
    self.fetchedResultsController = frc;
    return [frc autorelease];
}

- initInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (context) {
        self = [super initWithStyle:UITableViewStylePlain];
        if (self) self.fetchedResultsController = [self getFetchedResultsControllerInContext:context];
    } else {
        [self release];
        self = nil;
    }
    self.title = @"My Lost Items";
    return self;
}

#define MAP_BUTTON_TITLE @"Map"
#define LIST_BUTTON_TITLE @"List"
- (void)toggleMap:(UIBarButtonItem *)sender
{
    if (self.mapView.isHidden) {
        [self.mapView addAnnotations:self.fetchedResultsController.fetchedObjects];
        self.mapView.hidden = NO;
        self.tableView.hidden = YES;
        self.navigationItem.rightBarButtonItem.title = LIST_BUTTON_TITLE;
    } else {
        self.tableView.hidden = NO;
        self.mapView.hidden = YES;
        self.navigationItem.rightBarButtonItem.title = MAP_BUTTON_TITLE;
    }
}

// called whenever the MapView needs to display an annotation
// we return an MKPinAnnotation with a callout and a disclosure button
- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == self.mapView.userLocation) return nil;
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:@"MK"];
    if (!aView) {
        aView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MK"] autorelease];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.canShowCallout = YES;
    }
    aView.annotation = annotation;
    return aView;
}

// called when the detail disclosure button is pressed
//   in the callout of an annotation view
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = view.annotation;
    if ([annotation isKindOfClass:[LostItem class]]) {
        LostItem *lostItem = (LostItem *)view.annotation;
        LostItemInfoPageViewController *liipvc = [[LostItemInfoPageViewController alloc] init];
        liipvc.isMyItem = YES;
        liipvc.context = self.fetchedResultsController.managedObjectContext;
        liipvc.lostItem = lostItem;
        [self.navigationController pushViewController:liipvc animated:YES];
        [liipvc release];
    }
}

#define SEARCH_RADIUS 0.1
-(void)setInitialMap 
{
    CLLocationCoordinate2D centerCoordinate;
    if (self.itemLatitude && self.itemLongitude) {
        centerCoordinate.latitude = self.itemLatitude;
        centerCoordinate.longitude = self.itemLongitude;
    } else {
        centerCoordinate.latitude = self.mapView.userLocation.location.coordinate.latitude;
        centerCoordinate.longitude = self.mapView.userLocation.location.coordinate.longitude;
    }
    MKCoordinateRegion initialRegion;
    MKCoordinateSpan initialMapSpan;
    initialMapSpan.latitudeDelta = SEARCH_RADIUS;
    initialMapSpan.longitudeDelta = SEARCH_RADIUS;
    initialRegion.span = initialMapSpan;
    initialRegion.center = centerCoordinate;
    
    [self.mapView setRegion:initialRegion animated:NO];
}

#pragma mark - View lifecycle

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!([self.mapView.annotations count] > 1)) [self.mapView addAnnotations:self.fetchedResultsController.fetchedObjects];
    [self setInitialMap];
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
}

#define ADD_BUTTON_Y 40
#define BUTTON_WIDTH 200
#define BUTTON_MARGIN 5
- (void)loadView
{
    [super loadView];
    NSLog(@"Count:%@", [self.fetchedResultsController.fetchedObjects count]);
    if ([self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)self.view;
        
        self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        
        [self.view addSubview:self.tableView];
        self.tableView.frame = self.view.bounds;
        [self.tableView setBackgroundColor:[UIColor colorWithRed:14/255.0 green:44/255.0 blue:78/255.0 alpha:1]];
        [self.view setBackgroundColor:[UIColor colorWithRed:220/255.0 green:229/255.0 blue:246/255.0 alpha:1]];
        [self.view addSubview:self.mapView];
        self.mapView.frame = self.view.bounds;
        
        self.mapView.hidden = YES;
        self.mapView.delegate = self;
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:MAP_BUTTON_TITLE
                                                                                   style:UIBarButtonItemStyleBordered 
                                                                                  target:self
                                                                                  action:@selector(toggleMap:)] autorelease];
        self.mapView.showsUserLocation = YES;
        [self.mapView.userLocation addObserver:self forKeyPath:@"location" 
                                       options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    self.mapView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

#define CELL_HEIGHT 100
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:aTableView cellForRowAtIndexPath:indexPath];
    LostItem *lostItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = lostItem.name;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = lostItem.features;
    cell.detailTextLabel.numberOfLines = 2;
    cell.imageView.image = [UIImage imageWithData:lostItem.thumbnailData];
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LostItem *lostItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    LostItemInfoPageViewController *liipvc = [[LostItemInfoPageViewController alloc] init];
    liipvc.isMyItem = YES;
    liipvc.context = self.fetchedResultsController.managedObjectContext;
    liipvc.lostItem = lostItem;
    [self.navigationController pushViewController:liipvc animated:YES];
    [liipvc release];
}

- (void)dealloc
{
    [tableView release];
    [mapView release];
    [super dealloc];
}

@end
