//
//  AFSearchBar.h
//  AFModule
//
//  Created by alfie on 2021/1/4.
//

#import <UIKit/UIKit.h>

@class AFSearchController;

@interface AFSearchBar : UISearchBar

/** AFSearchController */
@property (nonatomic, weak) AFSearchController <UISearchBarDelegate>  *searchController;

/** proxy */
- (id <UISearchBarDelegate>)proxy;



@end


