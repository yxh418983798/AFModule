//
//  AFSearchBar.m
//  AFModule
//
//  Created by alfie on 2021/1/4.
//

#import "AFSearchBar.h"

@interface AFSearchBar ()

@property (nonatomic, weak) id <UISearchBarDelegate>   proxy;

/** 记录父视图 */
@property (nonatomic, weak) UIView            *originalSuperView;

@end

@implementation AFSearchBar

- (void)setSearchController:(AFSearchController<UISearchBarDelegate> *)searchController {
    _searchController = searchController;
    [super setDelegate:self.searchController];
}

- (void)setDelegate:(id<UISearchBarDelegate>)delegate {
    [super setDelegate:self.searchController];
    self.proxy = delegate;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
}








@end
