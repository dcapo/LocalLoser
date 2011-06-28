//
//  CoreDataTableViewController.m
//
//  Created for Stanford CS193p Spring 2010
//

#import "CoreDataTableViewController.h"

// the following API has been made private so that students may learn more from using this class
// it will be more code to do things like set up their table view cell, but more instructive as well

@interface CoreDataTableViewController()

// key to use when displaying items in the table; defaults to the first sortDescriptor's key
@property (nonatomic, copy) NSString *titleKey;
// key to use when displaying items in the table for the subtitle; defaults to nil
@property (nonatomic, copy) NSString *subtitleKey;

// gets accessory type (e.g. disclosure indicator) for the given managedObject (default DisclosureIndicator)
- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject;

// returns an image (small size) to display in the cell (default is nil)
- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject;

// called from tableView:cellForManagedObject: to set up the cell
- (void)configureCell:(UITableViewCell *)cell forManagedObject:(NSManagedObject *)managedObject;
// this is the CoreDataTableViewController's version of tableView:cellForRowAtIndexPath:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject;

// called when a cell representing the specified managedObject is selected (does nothing by default)
- (void)managedObjectSelected:(NSManagedObject *)managedObject;

// called to see if the specified managed object is allowed to be deleted (default is NO)
- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject;

// called when the user commits a delete by hitting a Delete button in the user-interface (default is to do nothing)
// this method does not necessarily have to delete the object from the database
// (e.g. it might just change the object so that it does not match the fetched results controller's predicate anymore)
// whatever you do here, don't forget to save the managed object context afterwards
- (void)deleteManagedObject:(NSManagedObject *)managedObject;

@end

@implementation CoreDataTableViewController

#pragma mark - Properties

@synthesize fetchedResultsController;
@synthesize titleKey, subtitleKey, searchKey;

- (NSString *)titleKey
{
	if (!titleKey) {
		NSArray *sortDescriptors = [self.fetchedResultsController.fetchRequest sortDescriptors];
		if (sortDescriptors.count) {
			return [[sortDescriptors objectAtIndex:0] key];
		} else {
			return nil;
		}
	} else {
		return titleKey;
	}
}

#pragma mark - Search Bar

- (void)createSearchBarIfItDoesntExist
{
	if (self.searchKey.length) {
        if (self.tableView && !self.tableView.tableHeaderView) {
            UISearchBar *searchBar = [[UISearchBar alloc] init];
            searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
            self.searchDisplayController.searchResultsDelegate = self;
            self.searchDisplayController.searchResultsDataSource = self;
            self.searchDisplayController.delegate = self;
            [searchBar sizeToFit];
            self.tableView.tableHeaderView = searchBar;
            [searchBar release];
        }
	} else {
		self.tableView.tableHeaderView = nil;
	}
}

- (void)setSearchKey:(NSString *)aKey
{
    if (aKey != searchKey) {
        [searchKey release];
        searchKey = [aKey copy];
        [self createSearchBarIfItDoesntExist];
    }
}

#pragma mark - Fetching

- (void)performFetchForTableView:(UITableView *)tableView
{
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"[CoreDataTableViewController performFetchForTableView:] %@ (%@)", [error localizedDescription], [error localizedFailureReason]);
    }
    [tableView reloadData];
}

// this method returns either the normal fetched results controller property
//   if the requesting table view is our self.tableView
// or a modified one that has an extra predicate (the search) if the requesting
//   tableView is the searchDisplayController's results table view

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
	if (tableView == self.tableView) {
		if (self.fetchedResultsController.fetchRequest.predicate != normalPredicate) {
			[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
			self.fetchedResultsController.fetchRequest.predicate = normalPredicate;
			[self performFetchForTableView:tableView];
		}
		[currentSearchText release];
		currentSearchText = nil;
	} else if ((tableView == self.searchDisplayController.searchResultsTableView) && self.searchKey && ![currentSearchText isEqual:self.searchDisplayController.searchBar.text]) {
		[currentSearchText release];
		currentSearchText = [self.searchDisplayController.searchBar.text copy];
		NSString *searchPredicateFormat = [NSString stringWithFormat:@"%@ contains[c] %@", self.searchKey, @"%@"];
		NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:searchPredicateFormat, self.searchDisplayController.searchBar.text];
		[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
		self.fetchedResultsController.fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:searchPredicate, normalPredicate , nil]];
		[self performFetchForTableView:tableView];
	}
	return self.fetchedResultsController;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
	// reset the fetch controller for the main (non-searching) table view
	[self fetchedResultsControllerForTableView:self.tableView];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)controller
{
	fetchedResultsController.delegate = nil;
    [controller retain];
	[fetchedResultsController release];
	fetchedResultsController = controller;
	controller.delegate = self;
	normalPredicate = [controller.fetchRequest.predicate retain];
	if (!self.title) self.title = controller.fetchRequest.entity.name;
	if (self.view.window) [self performFetchForTableView:self.tableView];
}

#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self createSearchBarIfItDoesntExist];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    if (!self.fetchedResultsController.fetchedObjects) {
        [self performFetchForTableView:self.tableView];
    }
}

#pragma mark - Overridable API

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject
{
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject
{
	return nil;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
    return NO;
}

- (void)configureCell:(UITableViewCell *)cell forManagedObject:(NSManagedObject *)managedObject
{
	if (self.titleKey) cell.textLabel.text = [[managedObject valueForKey:self.titleKey] description];
	if (self.subtitleKey) cell.detailTextLabel.text = [[managedObject valueForKey:self.subtitleKey] description];
	cell.accessoryType = [self accessoryTypeForManagedObject:managedObject];
	UIImage *thumbnail = [self thumbnailImageForManagedObject:managedObject];
	if (thumbnail) cell.imageView.image = thumbnail;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject
{
    static NSString *ReuseIdentifier = @"CoreDataTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ReuseIdentifier] autorelease];
    }
	
    [self configureCell:cell forManagedObject:managedObject];
	
	return cell;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
        [self deleteManagedObject:managedObject];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {  // can not delete from search results table view
        NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
        return [self canDeleteManagedObject:managedObject];
    } else {
        return NO;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	return [self tableView:tableView cellForManagedObject:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self managedObjectSelected:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{	
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{	
    UITableView *tableView = self.tableView;
	
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
			[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    if ([[self sectionIndexTitlesForTableView:self.tableView] count] > 1) {
        NSLog(@"CoreDataTableViewController: updating section indexes by reloading table (workaround)");
        [self.tableView reloadData];  // iOS bug workaround (section indexes don't update)
    }
}

#pragma mark - Memory Management

- (void)dealloc
{
	fetchedResultsController.delegate = nil;
	[fetchedResultsController release];
    searchController.delegate = nil;
    searchController.searchResultsDelegate = nil;
    searchController.searchResultsDataSource = nil;
    [searchController release];
	[searchKey release];
	[titleKey release];
	[currentSearchText release];
	[normalPredicate release];
    [super dealloc];
}

@end

