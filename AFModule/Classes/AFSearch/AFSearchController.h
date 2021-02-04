//
//  AFSearchController.h
//  AFModule
//
//  Created by alfie on 2021/1/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AFSearchController;
@protocol AFSearchControllerDelegate <NSObject>

- (void)willPresentSearchController:(AFSearchController *)searchController;
- (void)didPresentSearchController:(AFSearchController *)searchController;
- (void)willDismissSearchController:(AFSearchController *)searchController;
- (void)didDismissSearchController:(AFSearchController *)searchController;

- (Class)classFornavigationController;

@end


@protocol AFSearchResultsUpdating <NSObject>
@required
- (void)updateSearchResultsForSearchController:(AFSearchController *)searchController;

@end

@interface AFSearchController : NSObject

- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController;

@property (nonatomic, assign, getter = isActive) BOOL active;

@property (nonatomic, weak) id <AFSearchControllerDelegate> delegate;
@property (nonatomic, weak) id <AFSearchResultsUpdating> searchResultsUpdater;

@property (nonatomic, strong, readonly) UIViewController *searchResultsController;

- (UISearchBar *)searchBar;

@end



