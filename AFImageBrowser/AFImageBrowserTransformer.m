//
//  AFImageBrowserTransformer.m
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "AFImageBrowserTransformer.h"

@interface AFImageBrowserTransformer ()

/** 是否手势 */
@property (assign, nonatomic) BOOL            isInteractive;

/** 手势方向，是否从上往下 */
@property (assign, nonatomic) BOOL            isDirectionDown;

/** 百分比控制 */
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentTransition;

/** YES：prensent -- NO：dismiss */
@property (nonatomic, assign) BOOL              isPresenting;

@property (nonatomic, weak) UIViewController    *sourceVc;

@property (nonatomic, weak) UIViewController    *presentedVc;

/** 转场View */
@property (strong, nonatomic) UIView            *trasitionView;

/** 背景 */
@property (strong, nonatomic) UIView            *backGroundView;

@end



@implementation AFImageBrowserTransformer
#pragma mark - 转场动画
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}


//自定义动画过程
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = UIColor.whiteColor;
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromVC.view;
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    
    
#pragma mark - present
    if (self.isPresenting) {
        self.sourceVc = fromVC;
        self.presentedVc = toVC;
        
        toView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        toView.hidden = YES;
        [containerView addSubview:toView];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        if ([toVC isKindOfClass:[UINavigationController class]]) {
            [[[(UINavigationController *)toVC viewControllers].firstObject view] addGestureRecognizer:pan];
        } else {
            [toView addGestureRecognizer:pan];
        }

        self.backGroundView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height))];
        self.backGroundView.backgroundColor = UIColor.blackColor;
        self.backGroundView.alpha = 0;
        [containerView addSubview:self.backGroundView];
        
        UIImageView *transitionView = [self.sourceDelegate transformer:self transitionViewForSourceControllerAtIndex:self.index];
        self.trasitionView = [[UIView alloc] initWithFrame:[self.sourceDelegate transformer:self frameForSourceControllerAtIndex:self.index]];
        self.trasitionView.layer.contents = (__bridge id)transitionView.image.CGImage;
        [containerView addSubview:self.trasitionView];
        transitionView.hidden = YES;
        
        CGFloat height = UIScreen.mainScreen.bounds.size.width * transitionView.image.size.height / transitionView.image.size.width;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveLinear animations:^{
            
            self.trasitionView.frame = CGRectMake(0, fmax((UIScreen.mainScreen.bounds.size.height - height)/2, 0), UIScreen.mainScreen.bounds.size.width, height);
            self.backGroundView.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            transitionView.hidden = NO;
            
            if ([transitionContext transitionWasCancelled]) {
                
                [self.backGroundView removeFromSuperview];
                [self.trasitionView removeFromSuperview];
                self.backGroundView = nil;
                self.trasitionView = nil;
            } else {
                toView.hidden = NO;
                [self.backGroundView removeFromSuperview];
                [self.trasitionView removeFromSuperview];
                self.backGroundView = nil;
                self.trasitionView = nil;
            }
        }];
    }
    
    else {

        UIView *snapView;
        if (@available(iOS 13.0, *)) {
            snapView = [toView snapshotViewAfterScreenUpdates:NO];
            snapView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            [containerView addSubview:snapView];
        } else {
            toView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            [containerView addSubview:toView];
            fromView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            [containerView addSubview:fromView];
        }
        
        
        UIImageView *sourceView = [self.sourceDelegate transformer:self transitionViewForSourceControllerAtIndex:self.index];
        sourceView.hidden = YES;

        self.backGroundView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height))];
        self.backGroundView.backgroundColor = UIColor.blackColor;
        self.backGroundView.alpha = 1;
        [containerView addSubview:self.backGroundView];

        UIView *transitionView  = [self.presentedDelegate transformer:self transitionViewForPresentedControllerAtIndex:self.index];
        self.trasitionView = [transitionView snapshotViewAfterScreenUpdates:NO];
        CGFloat height = UIScreen.mainScreen.bounds.size.width * sourceView.image.size.height / sourceView.image.size.width;
        self.trasitionView.frame = CGRectMake(0, fmax((UIScreen.mainScreen.bounds.size.height - height)/2, 0), UIScreen.mainScreen.bounds.size.width, height);
        [containerView addSubview:self.trasitionView];
        fromView.hidden = YES;

        CGRect endFrame = [self.sourceDelegate transformer:self frameForSourceControllerAtIndex:self.index];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{

            self.backGroundView.alpha = 0;
            if (!self.isInteractive) {
                self.trasitionView.frame = endFrame;
            }

        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            sourceView.hidden = NO;

            if ([transitionContext transitionWasCancelled]) {
//                MOLog(@"-------------------------- 取消转场 --------------------------");
                fromView.hidden = NO;
                [self.trasitionView removeFromSuperview];
                [self.backGroundView removeFromSuperview];
                [snapView removeFromSuperview];
                self.backGroundView = nil;
                self.trasitionView = nil;

            } else {
//                MOLog(@"-------------------------- 完成转场:%@ --------------------------", toVC.view);
                [self.trasitionView removeFromSuperview];
                [self.backGroundView removeFromSuperview];
                [snapView removeFromSuperview];
                self.backGroundView = nil;
                self.trasitionView = nil;
            }
        }];
        
        
        
        
//        toView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
//        [containerView addSubview:toView];
//        fromView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
//        [containerView addSubview:fromView];
//
//        UIImageView *sourceView = [self.sourceDelegate transformer:self transitionViewForSourceControllerAtIndex:self.index];
//        sourceView.hidden = YES;
//
//        self.backGroundView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, XH_Width, XH_Height))];
//        self.backGroundView.backgroundColor = UIColor.blackColor;
//        self.backGroundView.alpha = 1;
//        [containerView addSubview:self.backGroundView];
//
//        UIView *transitionView = [self.presentedDelegate transformer:self transitionViewForPresentedControllerAtIndex:self.index];
//        self.trasitionView = [transitionView snapshotViewAfterScreenUpdates:NO];
//        CGFloat height = UIScreen.mainScreen.bounds.size.width * sourceView.image.size.height / sourceView.image.size.width;
//        self.trasitionView.frame = CGRectMake(0, (UIScreen.mainScreen.bounds.size.height - height)/2, UIScreen.mainScreen.bounds.size.width, height);
//        [containerView addSubview:self.trasitionView];
//        fromView.hidden = YES;
//
//
//        CGRect endFrame = [self.sourceDelegate transformer:self frameForSourceControllerAtIndex:self.index];
//        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
//
//            self.backGroundView.alpha = 0;
//            if (!self.isInteractive) {
//                self.trasitionView.frame = endFrame;
//            }
//
//        } completion:^(BOOL finished) {
//            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//            sourceView.hidden = NO;
//
//            if ([transitionContext transitionWasCancelled]) {
//
//                fromView.hidden = NO;
//                [self.trasitionView removeFromSuperview];
//                [self.backGroundView removeFromSuperview];
//                self.backGroundView = nil;
//                self.trasitionView = nil;
//
//            } else {
//                [self.trasitionView removeFromSuperview];
//                [self.backGroundView removeFromSuperview];
//                self.backGroundView = nil;
//                self.trasitionView = nil;
//            }
//        }];
    }
}
//UIView *snapView = [toView snapshotViewAfterScreenUpdates:NO];
//        snapView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
//        [containerView addSubview:snapView];
////        fromView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
////        [containerView addSubview:fromView];
//
//        UIImageView *sourceView = [self.sourceDelegate transformer:self transitionViewForSourceControllerAtIndex:self.index];
//        sourceView.hidden = YES;
//
//        self.backGroundView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, XH_Width, XH_Height))];
//        self.backGroundView.backgroundColor = UIColor.blackColor;
//        self.backGroundView.alpha = 1;
//        [containerView addSubview:self.backGroundView];
//
//        UIView *transitionView = [self.presentedDelegate transformer:self transitionViewForPresentedControllerAtIndex:self.index];
//        self.trasitionView = [transitionView snapshotViewAfterScreenUpdates:NO];
//        CGFloat height = UIScreen.mainScreen.bounds.size.width * sourceView.image.size.height / sourceView.image.size.width;
//        self.trasitionView.frame = CGRectMake(0, (UIScreen.mainScreen.bounds.size.height - height)/2, UIScreen.mainScreen.bounds.size.width, height);
//        [containerView addSubview:self.trasitionView];
////        fromView.hidden = YES;
//
//
//        CGRect endFrame = [self.sourceDelegate transformer:self frameForSourceControllerAtIndex:self.index];
//        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
//
//            self.backGroundView.alpha = 0;
//            if (!self.isInteractive) {
//                self.trasitionView.frame = endFrame;
//            }
//
//        } completion:^(BOOL finished) {
//            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//            sourceView.hidden = NO;
//
//            if ([transitionContext transitionWasCancelled]) {
//                XHLog(@"-------------------------- 取消转场 --------------------------");
////                fromView.hidden = NO;
//                [self.trasitionView removeFromSuperview];
//                [self.backGroundView removeFromSuperview];
//                [snapView removeFromSuperview];
//                self.backGroundView = nil;
//                self.trasitionView = nil;
//
//            } else {
//                XHLog(@"-------------------------- 完成转场:%@ --------------------------", toVC.view);
//                [self.trasitionView removeFromSuperview];
//                [self.backGroundView removeFromSuperview];
//                [snapView removeFromSuperview];
//                self.backGroundView = nil;
//                self.trasitionView = nil;
//            }
//        }];


#pragma mark -- UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.isPresenting = YES;
    self.sourceVc = source;
    self.presentedVc = presented;
    return self;
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.isPresenting = NO;
    self.presentedVc = dismissed;
    return self;
}


- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.percentTransition;
}


- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.percentTransition;
}



#pragma mark - dismiss
- (void)dismiss {
    [self.presentedVc dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - 百分比手势的监听方法
- (void)panAction:(UIScreenEdgePanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:[UIApplication sharedApplication].keyWindow];
    CGFloat progress = fabs(point.y / [UIApplication sharedApplication].keyWindow.bounds.size.height);
    progress = fmin(1, progress);
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.isInteractive = YES;
            self.isDirectionDown = (point.y > 0);
            self.percentTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            [self.presentedVc dismissViewControllerAnimated:YES completion:nil];
            break;
            
        case UIGestureRecognizerStateChanged: {
            self.backGroundView.alpha = fmax(1-progress*3, 0);
            UIImageView *sourceView = [self.sourceDelegate transformer:self transitionViewForSourceControllerAtIndex:self.index];
            CGFloat original_H = UIScreen.mainScreen.bounds.size.width * sourceView.image.size.height / sourceView.image.size.width;
            CGFloat original_Y;
            if (self.isDirectionDown) {
                original_Y = fmax((UIScreen.mainScreen.bounds.size.height - original_H)/2, 0);
            } else {
                original_Y = fmax((UIScreen.mainScreen.bounds.size.height - original_H)/2, original_H - UIScreen.mainScreen.bounds.size.height);
            }
            CGFloat distance_W = (UIScreen.mainScreen.bounds.size.width - sourceView.frame.size.width) * progress;
            CGFloat current_W = UIScreen.mainScreen.bounds.size.width - distance_W;
            CGFloat scale = current_W / UIScreen.mainScreen.bounds.size.width;
            self.trasitionView.frame = CGRectMake(distance_W/2 + point.x, original_Y + point.y, current_W, original_H * scale);
            [self.percentTransition updateInteractiveTransition:progress];
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            
            self.isInteractive = NO;

            if(progress > 0.2){
                
                CGRect endFrame = [self.sourceDelegate transformer:self frameForSourceControllerAtIndex:self.index];
                [UIView animateWithDuration:0.25 animations:^{
                    self.trasitionView.frame = endFrame;
                    self.backGroundView.alpha = 0;
                } completion:^(BOOL finished) {
                    [self.percentTransition finishInteractiveTransition];
                    self.percentTransition = nil;
                }];
            }else{
                UIImageView *sourceView = [self.sourceDelegate transformer:self transitionViewForSourceControllerAtIndex:self.index];
                CGFloat height = UIScreen.mainScreen.bounds.size.width * sourceView.image.size.height / sourceView.image.size.width;
                self.backGroundView.alpha = fmax(1-progress*3, 0);
                [UIView animateWithDuration:0.25 animations:^{
                    
                    if (self.isDirectionDown) {
                        self.trasitionView.frame = CGRectMake(0, fmax((UIScreen.mainScreen.bounds.size.height - height)/2, 0), UIScreen.mainScreen.bounds.size.width, height);
                    } else {
                        self.trasitionView.frame = CGRectMake(0, fmax((UIScreen.mainScreen.bounds.size.height - height)/2, height - UIScreen.mainScreen.bounds.size.height), UIScreen.mainScreen.bounds.size.width, height);
                    }
                    self.backGroundView.alpha = 1;
                } completion:^(BOOL finished) {
                    [self.percentTransition cancelInteractiveTransition];
                    self.percentTransition = nil;
                }];
            }
            
        default:
            break;
    }
}


- (void)startInteractiveTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
}


@end
