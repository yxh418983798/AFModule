//
//  AFSearchController.m
//  AFModule
//
//  Created by alfie on 2021/1/4.
//

#import "AFSearchController.h"
#import "AFSearchBar.h"

@interface AFSearchController () <UISearchBarDelegate>

@property (nonatomic, strong) AFSearchBar *searchBar;

@end

@implementation AFSearchController

#pragma mark - 构造方法
- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController {
    if (self = [super init]) {
        _searchResultsController = searchResultsController;
    }
    return self;
}


#pragma mark - UI
- (UISearchBar *)searchBar {
    if (!_searchBar) {
        AFSearchBar *searchBar = AFSearchBar.new;
        searchBar.searchController = self;
        _searchBar = searchBar;
    }
    return _searchBar;
}
    

#pragma mark - 展示/隐藏
- (void)setActive:(BOOL)active {
    if (_active != active) {
        _active = active;
        if (active) {
            Class naviClass = UINavigationController.class;
            if ([self.delegate respondsToSelector:@selector(classFornavigationController)]) {
                naviClass = self.delegate.classFornavigationController;
            }
            UINavigationController *navi = [[naviClass alloc] initWithRootViewController:_searchResultsController];
            [self.currentVc presentViewController:navi animated:YES completion:nil];
        } else {
            [_searchResultsController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


#pragma mark - 获取当前控制器
- (UIViewController *)currentVc {
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) result = result.presentedViewController;
    return result;
}


#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    BOOL shouldBegin = YES;
    if ([_searchBar.proxy respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        shouldBegin = [_searchBar.proxy searchBarShouldBeginEditing:searchBar];
    }
    if (shouldBegin) {
        self.active = YES;
    }
    return shouldBegin;
}
    
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([_searchBar.proxy respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [_searchBar.proxy searchBarTextDidBeginEditing:searchBar];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if ([_searchBar.proxy respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        return [_searchBar.proxy searchBarShouldEndEditing:searchBar];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([_searchBar.proxy respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [_searchBar.proxy searchBarTextDidEndEditing:searchBar];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([_searchBar.proxy respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [_searchBar.proxy searchBar:searchBar textDidChange:searchText];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([_searchBar.proxy respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [_searchBar.proxy searchBar:searchBar shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([_searchBar.proxy respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [_searchBar.proxy searchBarSearchButtonClicked:searchBar];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    if ([_searchBar.proxy respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) {
        [_searchBar.proxy searchBarBookmarkButtonClicked:searchBar];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    if ([_searchBar.proxy respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [_searchBar.proxy searchBarCancelButtonClicked:searchBar];
    }
    self.active = NO;
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    
    if ([_searchBar.proxy respondsToSelector:@selector(searchBarResultsListButtonClicked:)]) {
        [_searchBar.proxy searchBarResultsListButtonClicked:searchBar];
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if ([_searchBar.proxy respondsToSelector:@selector(searchBar:selectedScopeButtonIndexDidChange:)]) {
        [_searchBar.proxy searchBar:searchBar selectedScopeButtonIndexDidChange:selectedScope];
    }
}

 


@end
