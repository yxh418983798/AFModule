//
//  AFImageBrowserTransformer.h
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFImageBrowserTransformer;
@protocol AFImageBrowserSourceTransformerDelegate <NSObject>

/*
 * 源控制器的转场View
 */
- (UIImageView *)transformer:(AFImageBrowserTransformer *)transformer transitionViewForSourceControllerAtIndex:(NSInteger)index;

/*
 * 源控制器的结束frame
 */
- (CGRect)transformer:(AFImageBrowserTransformer *)transformer frameForSourceControllerAtIndex:(NSInteger)index;


@end


@protocol AFImageBrowserPresentedTransformerDelegate <NSObject>

/*
 * 推出控制器的转场View
 */
- (UIView *)transformer:(AFImageBrowserTransformer *)transformer transitionViewForPresentedControllerAtIndex:(NSInteger)index;

/*
 * 推出控制器的起始frame
 */
- (CGRect)transformer:(AFImageBrowserTransformer *)transformer frameForPresentedControllerAtIndex:(NSInteger)index;

@end



@interface AFImageBrowserTransformer : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning>

/** 源控制器代理 */
@property (weak, nonatomic) id <AFImageBrowserSourceTransformerDelegate>        sourceDelegate;

/** 推出控制器代理 */
@property (weak, nonatomic) id <AFImageBrowserPresentedTransformerDelegate>     presentedDelegate;

/** index */
@property (assign, nonatomic) NSInteger                                         index;

@end


