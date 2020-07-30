//
//  AFTimer.m
//  AFWorkSpace
//
//  Created by alfie on 2019/6/5.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "AFTimer.h"
#import <QuartzCore/CADisplayLink.h>

typedef NS_ENUM(NSInteger, AFTimerOption) {
    AFTimerOptionTimerTarget,
    AFTimerOptionDisplayLink,
    AFTimerOptionGCD,
};


@interface AFTimer ()

/** 定时器 */
@property (strong, nonatomic) NSTimer            *timer;

/** displayLink */
@property (strong, nonatomic) CADisplayLink      *displayLink;

/** gcd定时器 */
@property (strong, nonatomic) dispatch_source_t  gcd_timer;

/** target */
@property (weak, nonatomic) id                   target;

/** 执行方法 */
@property (assign, nonatomic) SEL                selector;

/** 间隔时间 */
@property (assign, nonatomic) NSTimeInterval     interval;

/** 是否重复 */
@property (assign, nonatomic) BOOL               repeats;

/** runloopMode */
@property (assign, nonatomic) NSRunLoopMode      runloopMode;

/** 定时器类型 */
@property (assign, nonatomic) AFTimerOption      timerOption;

/** gcd定时器的线程 */
@property (strong, nonatomic) dispatch_queue_t   queue;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation AFTimer
#pragma mark -- 生命周期
+ (AFTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats forMode:(NSRunLoopMode)mode {
    
    AFTimer *timer = [AFTimer new];
    timer.target = target ?: timer;
    timer.selector = selector;
    timer.runloopMode = mode;
    timer.interval = interval;
    timer.repeats = repeats;
    timer.timerOption = AFTimerOptionTimerTarget;
    [timer setValue:userInfo forKey:@"_userInfo"];
    return timer;
}


+ (AFTimer *)displayLinkWithFrameInterval:(NSInteger)interval target:(id)target selector:(SEL)selector userInfo:(id)userInfo forMode:(NSRunLoopMode)mode {
    
    AFTimer *timer = [AFTimer new];
    timer.target = target ?: timer;
    timer.interval = interval;
    timer.selector = selector;
    timer.runloopMode = mode;
    timer.timerOption = AFTimerOptionDisplayLink;
    [timer setValue:userInfo forKey:@"_userInfo"];
    return timer;
}


+ (AFTimer *)GCDTimerWithInterval:(NSInteger)interval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats queue:(nonnull dispatch_queue_t)queue {
    
    AFTimer *timer = [AFTimer new];
    timer.target = target ?: timer;
    timer.selector = selector;
    timer.interval = interval;
    timer.repeats = repeats;
    timer.timerOption = AFTimerOptionGCD;
    timer.queue = queue ?: dispatch_get_main_queue();
    [timer setValue:userInfo forKey:@"_userInfo"];
    return timer;
}



#pragma mark -- 代理执行方法
- (void)timerAction {
    if (self.isValid && self.target) {
        [self.target performSelector:self.selector withObject:self];
    } else {
        [self invalidate];
    }
}



#pragma mark -- 启动
- (void)fire {
    
    switch (self.timerOption) {
        case AFTimerOptionTimerTarget: {
            if (self.timer) {
                [self.timer invalidate];
                self.timer = nil;
            }
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(timerAction) userInfo:self.userInfo repeats:self.repeats];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:self.runloopMode];
        }
            break;
            
        case AFTimerOptionDisplayLink: {
            if (self.displayLink) {
                [self.displayLink invalidate];
                self.displayLink = nil;
            }
            
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerAction)];
            self.displayLink.frameInterval = self.interval;
            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:self.runloopMode];
        }
            break;
            
        case AFTimerOptionGCD: {
            if (self.gcd_timer) {
                dispatch_cancel(self.gcd_timer);
                self.gcd_timer = nil;
            }
            self.gcd_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
            dispatch_source_set_timer(self.gcd_timer, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), (uint64_t)(self.interval * NSEC_PER_SEC), 0);
            dispatch_source_set_event_handler(self.gcd_timer, ^{
                [self timerAction];
                if (!self.repeats) {
                    [self invalidate];
                }
            });
            dispatch_resume(self.gcd_timer);
        }
            break;
            
        default:
            break;
    }
}



#pragma mark -- 停止
- (void)invalidate {
    
    switch (self.timerOption) {
        case AFTimerOptionTimerTarget: {
            [self.timer invalidate];
            self.timer = nil;
        }
            break;
            
        case AFTimerOptionDisplayLink: {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
            break;
            
        case AFTimerOptionGCD: {
            dispatch_cancel(self.gcd_timer);
            self.gcd_timer = nil;
        }
            break;
            
        default:
            break;
    }
}



#pragma mark -- 状态
- (BOOL)isValid {
    switch (self.timerOption) {
        case AFTimerOptionTimerTarget:
            return (BOOL)self.timer;
        case AFTimerOptionDisplayLink:
            return (BOOL)self.displayLink;
        case AFTimerOptionGCD:
            return (BOOL)self.gcd_timer;
        default:
            return NO;
    }
}



@end
#pragma clang diagnostic pop
