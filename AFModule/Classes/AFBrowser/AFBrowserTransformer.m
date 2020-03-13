//
//  AFBrowserTransformer.m
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "AFBrowserTransformer.h"

@interface AFBrowserTransformer ()

/** 是否手势交互 */
@property (assign, nonatomic) BOOL            isInteractive;

/** 手势方向，是否从上往下 */
@property (assign, nonatomic) BOOL            isDirectionDown;

/** 浏览器imageView的高度 */
@property (assign, nonatomic) CGFloat         imgView_H;

/** 百分比控制 */
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentTransition;

/** YES：prensent -- NO：dismiss */
@property (nonatomic, assign) BOOL              isPresenting;

/** 源控制器 */
@property (nonatomic, weak) UIViewController    *sourceVc;

/** 推出的控制器 */
@property (nonatomic, weak) UIViewController    *presentedVc;

/** 转场View */
@property (strong, nonatomic) UIView            *trasitionView;

/** 背景 */
@property (strong, nonatomic) UIView            *backGroundView;

/** presentedTrasitionView的原始frame */
@property (assign, nonatomic) CGRect            presentedTrasitionViewFrame;

@end



@implementation AFBrowserTransformer
#pragma mark - 转场动画
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}


- (CGRect)sourceFrame {
    CGRect frame = [self.sourceDelegate frameForSourceController];
    if (frame.size.width < 1) {
        NSLog(@"-------------------------- sourceFrame有问题，请检查代码 frame:%@  sourceView：%@--------------------------", NSStringFromCGRect(frame), [self.sourceDelegate transitionViewForSourceController]);
        frame.size.width = 1;
    }
    if (frame.size.height < 1) {
        frame.size.height = 1;
    }
//    frame.size.width = fmax(frame.size.width, 1);
//    frame.size.height = fmax(frame.size.height, 1);
    return frame;
}

- (UIView *)presentedTransitionView {
    UIView *transitionView = [self.presentedDelegate transitionViewForPresentedController];
    if (!transitionView && self.type == AFBrowserItemTypeImage) {
        UIImageView *imageView = [UIImageView new];
        imageView.image = [UIImage new];
        NSLog(@"-------------------------- presentedTransitionView是空的！请检查代码 --------------------------");
        return imageView;
    }
    return transitionView;
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
        if (![self.sourceDelegate respondsToSelector:@selector(transitionViewForSourceController)] || ![self.sourceDelegate transitionViewForSourceController] || self.userDefaultAnimation) {

            toView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            [containerView addSubview:toView];
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
                toView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
            return;
        }

        
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
        
        UIImageView *transitionView = [self.sourceDelegate transitionViewForSourceController];    
        self.trasitionView = [[UIView alloc] initWithFrame:self.sourceFrame];
        self.trasitionView.layer.contents = (__bridge id)transitionView.image.CGImage;
        [containerView addSubview:self.trasitionView];
        transitionView.hidden = YES;
        
        CGFloat height = UIScreen.mainScreen.bounds.size.width * fmax(transitionView.image.size.height, 1) / fmax(transitionView.image.size.width, 1);
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:0 animations:^{

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
            snapView = [toView snapshotViewAfterScreenUpdates:YES];
            snapView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            [containerView addSubview:snapView];
        } else {
            toView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            [containerView addSubview:toView];
            fromView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            [containerView addSubview:fromView];
        }
        
        if (![self.sourceDelegate respondsToSelector:@selector(transitionViewForSourceController)] || ![self.sourceDelegate transitionViewForSourceController] || self.userDefaultAnimation) {
            fromView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            [containerView addSubview:fromView];
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
                fromView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
            return;
        }

        UIImageView *sourceView = [self.sourceDelegate transitionViewForSourceController];
        sourceView.hidden = self.hideSourceViewWhenTransition;
        
        self.backGroundView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height))];
        self.backGroundView.backgroundColor = UIColor.blackColor;
        self.backGroundView.alpha = 1;
        [containerView addSubview:self.backGroundView];

        if (self.type == AFBrowserItemTypeImage) {
            UIImageView *transitionView = (UIImageView *)self.presentedTransitionView;
            self.trasitionView = [transitionView snapshotViewAfterScreenUpdates:NO];
            CGFloat height = UIScreen.mainScreen.bounds.size.width * fmax(transitionView.image.size.height, 1) / fmax(transitionView.image.size.width, 1);
            self.trasitionView.frame = CGRectMake(0, fmax((UIScreen.mainScreen.bounds.size.height - height)/2, 0), UIScreen.mainScreen.bounds.size.width, height);
            self.presentedTrasitionViewFrame = self.trasitionView.frame;
            [containerView addSubview:self.trasitionView];
            fromView.hidden = YES;

            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:0 animations:^{

                self.backGroundView.alpha = 0;
                if (!self.isInteractive) {
                    self.trasitionView.frame = self.sourceFrame;
                }

            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                sourceView.hidden = NO;
                
                if ([transitionContext transitionWasCancelled]) {
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
        } else {
            self.trasitionView = self.presentedTransitionView;
            UIView *superView = self.trasitionView.superview;
            NSInteger index = [superView.subviews indexOfObject:self.trasitionView];
            self.presentedTrasitionViewFrame = self.trasitionView.frame;
            [self.trasitionView removeFromSuperview];
            [containerView addSubview:self.trasitionView];
            fromView.hidden = YES;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:0 animations:^{

                self.backGroundView.alpha = 0;
                if (!self.isInteractive) {
                    self.trasitionView.frame = self.sourceFrame;
                }
                
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                sourceView.hidden = NO;
                [self.trasitionView removeFromSuperview];
                [self.backGroundView removeFromSuperview];
                [snapView removeFromSuperview];
                if ([transitionContext transitionWasCancelled]) {
                    fromView.hidden = NO;
                    self.trasitionView.frame = self.presentedTrasitionViewFrame;
                    [superView insertSubview:self.trasitionView atIndex:index];
                } else {
                }
                self.trasitionView = nil;
                self.backGroundView = nil;
            }];
        }
    }
}



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
        case UIGestureRecognizerStateBegan: {
            self.isInteractive = YES;
            self.isDirectionDown = (point.y > 0);
            self.percentTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            [self.presentedVc dismissViewControllerAnimated:YES completion:nil];
            if (self.type == AFBrowserItemTypeImage) {
                UIImageView *transitionView  = (UIImageView *)self.presentedTransitionView;
                self.imgView_H = UIScreen.mainScreen.bounds.size.width * fmax(transitionView.image.size.height, 1) / fmax(transitionView.image.size.width, 1);
            } else {
                self.trasitionView = self.presentedTransitionView;
                self.imgView_H = self.trasitionView.frame.size.height;
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            self.backGroundView.alpha = fmax(1-progress*3, 0);
            CGFloat original_Y;
            if (self.isDirectionDown) {
                original_Y = fmax((UIScreen.mainScreen.bounds.size.height - self.imgView_H)/2, 0);
            } else {
                original_Y = fmax((UIScreen.mainScreen.bounds.size.height - self.imgView_H)/2, self.imgView_H - UIScreen.mainScreen.bounds.size.height);
            }
            CGFloat distance_W = (UIScreen.mainScreen.bounds.size.width - self.sourceFrame.size.width) * progress;
            CGFloat current_W = UIScreen.mainScreen.bounds.size.width - distance_W;
            CGFloat scale = current_W / UIScreen.mainScreen.bounds.size.width;
            self.trasitionView.frame = CGRectMake(distance_W/2 + point.x, original_Y + point.y, current_W, self.imgView_H * scale);
            [self.percentTransition updateInteractiveTransition:progress];
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            
            self.isInteractive = NO;
            if(progress > 0.2){
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
                    self.trasitionView.frame = self.sourceFrame;
                    self.backGroundView.alpha = 0;
                } completion:^(BOOL finished) {
                    [self.percentTransition finishInteractiveTransition];
                    self.percentTransition = nil;
                }];
            }else{
                self.backGroundView.alpha = 1;
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
                    self.trasitionView.frame = self.presentedTrasitionViewFrame;
                } completion:^(BOOL finished) {
                    [self.percentTransition cancelInteractiveTransition];
                    self.percentTransition = nil;
                }];
            }
            
        default:
            break;
    }
}


- (void)startInteractiveTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {}


@end
