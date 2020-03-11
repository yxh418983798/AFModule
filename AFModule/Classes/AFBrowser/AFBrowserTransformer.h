//
//  AFBrowserTransformer.h
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFBrowserItem.h"

@class AFBrowserTransformer;
@protocol AFBrowserSourceTransformerDelegate <NSObject>

/*
 * 源控制器的转场View
 */
- (UIImageView *)transitionViewForSourceController;


/*
 * 源控制器的结束frame
 */
- (CGRect)frameForSourceController;


@end


@protocol AFBrowserPresentedTransformerDelegate <NSObject>

/*
 * 推出控制器的转场View
 */
- (UIView *)transitionViewForPresentedController;


@optional;
/*
 * 推出控制器的起始frame
 */
- (CGRect)frameForPresentedController;


@end



@interface AFBrowserTransformer : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning>

/** 转场时，是否隐藏源视图 */
@property (assign, nonatomic) BOOL               hideSourceViewWhenTransition;

/** AFBrowserItemType */
@property (assign, nonatomic) AFBrowserItemType  type;

/** 源控制器代理 */
@property (weak, nonatomic) id <AFBrowserSourceTransformerDelegate>     sourceDelegate;

/** 推出控制器代理 */
@property (weak, nonatomic) id <AFBrowserPresentedTransformerDelegate>  presentedDelegate;

@end


