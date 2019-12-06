//
//  AFTimer.h
//  AFWorkSpace
//
//  Created by alfie on 2019/6/5.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AFTimer : NSObject

/**
 NSTimer实现定时器，该方法是安全的，不会造成内存泄露
 
 @param interval 间隔多少秒执行一次

 @param target 执行方法的对象，定时器会自动跟随target释放
 
 @param mode 在指定的RunLoopMode下执行
 
 @return 需要手动调用fire来启动定时器
 */
+ (AFTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats forMode:(NSRunLoopMode)mode;


/**
 CADisplayLink实现定时器，该方法是安全的，不会造成内存泄露
 
 @param interval 间隔多少帧执行一次

 @param target 执行方法的对象，定时器会自动跟随target释放

 @param mode 在指定的RunLoopMode下执行
 
 @return 需要手动调用fire来启动定时器
 */
+ (AFTimer *)displayLinkWithFrameInterval:(NSInteger)interval target:(id)target selector:(SEL)selector userInfo:(id)userInfo forMode:(NSRunLoopMode)mode;


/**
 GCD实现定时器，该方法是安全的，不会造成内存泄露
 
 @param interval 间隔多少秒执行一次
 
 @param target 执行方法的对象，定时器会自动跟随target释放

 @param queue 当给nil时，默认在主线程中执行

 @return 需要手动调用fire来启动定时器
 */
+ (AFTimer *)GCDTimerWithInterval:(NSInteger)interval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats queue:(dispatch_queue_t)queue;


/**
 * userInfo
 */
@property (strong, nonatomic, readonly) id  userInfo;


/**
 * 标记定时器的Tag
 */
@property (assign, nonatomic) NSInteger     tag;


/**
 * 获取定时器状态，是否在执行中
 */
- (BOOL)isValid;


/**
 * 启动定时器
 */
- (void)fire;


/**
 * 停止定时器
 */
- (void)invalidate;


@end


