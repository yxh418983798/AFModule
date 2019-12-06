//
//  AFTimerViewController.m
//  AFModule_Example
//
//  Created by alfie on 2019/12/6.
//  Copyright © 2019 yxh418983798. All rights reserved.
//

#import "AFTimerViewController.h"
#import "AFTimer.h"

@interface AFTimerViewController ()

/** 定时器 */
@property (strong, nonatomic) AFTimer            *timer;

@end

@implementation AFTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _timer = [AFTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES forMode:(NSRunLoopCommonModes)];
    [_timer fire];
    
}


- (void)timerAction {
    NSLog(@"-------------------------- timerAction --------------------------");
}


- (void)dealloc {
    NSLog(@"-------------------------- dealloc --------------------------");
}


@end
