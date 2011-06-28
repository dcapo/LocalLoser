//
//  FoundItemsTableViewController.m
//  LostAndFound
//
//  Created by Daniel.
//  Copyright 2011. All rights reserved.
//

#import "FoundItemsTableViewController.h"
#import "FoundItemInfoPageViewController.h"
#import "FoundItemViewController.h"
#import "FoundItem.h"
#import "FoundItem_Create.h"
#import <MapKit/MapKit.h>

@interface FoundItemsTableViewController() <MKMapViewDelegate>
@property (retain) UITableView *tableView;
@property (nonatomic, retain) MKMapView *mapView;
@end

@implementation FoundItemsTableViewController

@synthesize tableView, mapView, itemLongitude, itemLatitude;

- (MKMapView *)mapView
{
    if (!mapView) {
        mapView = [[MKMapView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return mapView;
}

#pragma mark - Designated Initializer

// creates an NSFetchedResultsController with an NSFetchRequest
//   that fetches all Photographers (e.g. no predicate)
- initInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (context) {
        self = [super initWithStyle:UITableViewStylePlain];
        if (self) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = [NSEntityDescription entityForName:@"FoundItem"
                                              inManagedObjectContext:context];
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
            [frc release];
        }
    } else {
        [self release];
        self = nil;
    }
    self.title = @"Found Items";
    return self;
}

#define MAP_BUTTON_TITLE @"Map"
#define LIST_BUTTON_TITLE @"List"
- (void)toggleMap:(UIBarButtonItem *)sender
{
    if (self.mapView.isHidden) {
        self.mapView.hidden = NO;
        self.tableView.hidden = YES;
        self.navigationItem.rightBarButtonItem.title = LIST_BUTTON_TITLE;
        if ([self.mapView.annotations count] <= 1) {
            [self.mapView addAnnotations:self.fetchedResultsController.fetchedObjects];
        }
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
    if ([annotation isKindOfClass:[FoundItem class]]) {
        FoundItem *foundItem = (FoundItem *)view.annotation;
        FoundItemInfoPageViewController *fiipvc = [[FoundItemInfoPageViewController alloc] init];
        fiipvc.foundItem = foundItem;
        fiipvc.context = self.fetchedResultsController.managedObjectContext;
        [self.navigationController pushViewController:fiipvc animated:YES];
        [fiipvc release];
    }
}

#define SEARCH_RADIUS 0.1
// Initializes the map to show the found/lost items near the posting clicked on 
// in the last tableview controller in the navigation stack. This is the purpose of itemLatitude and itemLongitude.
// By default, initializes the map to center around the user's location. 
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
    self.mapView.hidden = NO;
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
}

#define ADD_BUTTON_Y 40
#define BUTTON_WIDTH 300
- (void)loadView
{
    [super loadView];
    
    if ([self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)self.view;
        
        self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        
        [self.view addSubview:self.tableView];
        self.tableView.frame = self.view.bounds;
        [self.tableView setBackgroundColor:[UIColor colorWithRed:14/255.0 green:44/255.0 blue:78/255.0 alpha:1]];
        
        [self.view addSubview:self.mapView];
        self.mapView.frame = self.view.bounds;
        
        self.mapView.hidden = YES;
        self.tableView.hidden = YES;
        self.mapView.delegate = self;
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LIST_BUTTON_TITLE
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

#define ADD_FOUND_ITEM_FONT_SIZE 26.0f
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:aTableView cellForRowAtIndexPath:indexPath];
    FoundItem *foundItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = foundItem.name;
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = foundItem.features;
    cell.detailTextLabel.numberOfLines = 2;
    cell.imageView.image = [UIImage imageWithData:foundItem.thumbnailData];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoundItem *foundItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    FoundItemInfoPageViewController *fiipvc = [[FoundItemInfoPageViewController alloc] init];
    fiipvc.foundItem = foundItem;
    fiipvc.context = self.fetchedResultsController.managedObjectContext;
    [self.navigationController pushViewController:fiipvc animated:YES];
    [fiipvc release];
}

- (void)dealloc
{
    [tableView release];
    [mapView release];
    [super dealloc];
}

@end
