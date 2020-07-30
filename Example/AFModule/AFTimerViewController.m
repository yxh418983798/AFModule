//
//  AFTimerViewController.m
//  AFModule_Example
//
//  Created by alfie on 2019/12/6.
//  Copyright © 2019 yxh418983798. All rights reserved.
//

#import "AFTimerViewController.h"
#import "AFTimer.h"
#import "AFDeviceObserver.h"

@interface AFTimerViewController () <AFDeviceDelegate>

/** 定时器 */
@property (strong, nonatomic) AFTimer            *timer;

@end

@implementation AFTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof (self) weakSelf = self;

    [AFDeviceObserver getMuteStatus:^(BOOL isMute) {
        NSLog(@"-------------------------- 只检测一次啊：%d --------------------------", isMute);
        [AFDeviceObserver addMuteObserver:self];
    }];
    
    [AFDeviceObserver addCallObserver:self];
//    _timer = [AFTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES forMode:(NSRunLoopCommonModes)];
//    [_timer fire];
    
}


- (void)timerAction {
    NSLog(@"-------------------------- timerAction --------------------------");
}


- (void)dealloc {
    NSLog(@"-------------------------- dealloc --------------------------");
}

/// 状态改变的回调
- (void)deviceDidChangeMuteStatus:(BOOL)isMute {
    NSLog(@"-------------------------- 代理回调：%d --------------------------", isMute);
}

- (void)deviceDidChangeCallStatu:(NSString *)callStatus {
    NSLog(@"--------------------------来电：%@ --------------------------", callStatus);
}


@end
