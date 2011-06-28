//
//  CoreDataTableViewController.h
//
//  Created for Stanford CS193p Spring 2011
//
// This class mostly just copies the code from NSFetchedResultsController's documentation page
//   into a subclass of UITableViewController.

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>
{
@private
	NSPredicate *normalPredicate;
	NSString *currentSearchText;
	NSString *titleKey;
	NSString *subtitleKey;
	NSString *searchKey;
	NSFetchedResultsController *fetchedResultsController;
    UISearchDisplayController *searchController;
}

// the controller (this class does nothing if this is not set)
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

// creates a subtitle-style cell with the textLabel defaulting to the first sort descriptor's key
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// key to use when searching the table; if nil, no searching allowed
@property (nonatomic, copy) NSString *searchKey;

@end
