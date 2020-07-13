//
//  AFTextModuleViewController.m
//  AFModule_Example
//
//  Created by alfie on 2019/11/28.
//  Copyright © 2019 yxh418983798. All rights reserved.
//

#import "AFTextModuleViewController.h"
#import "AFTextModule.h"

@interface AFTextModuleViewController ()

/** textField */
@property (strong, nonatomic) UITextField           *textField;

/** textView */
@property (strong, nonatomic) UITextView            *textView;

@end

@implementation AFTextModuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    
    _textField = [UITextField new];
    _textField.frame = CGRectMake(50, 100, 200, 50);
    _textField.backgroundColor = UIColor.lightGrayColor;
    _textField.textColor = UIColor.blackColor;
    _textField.module.maxLenght = 3;
    // 设置 输入的限制类型
//    _textField.module.restrictOption = AFInputRestrictionOptionNumber;
    // 超出输入限制 的回调
    _textField.module.beyondRestrictionHandle = ^(AFInputRestrictionOptions restriction) {
        if (restriction == AFInputRestrictionOptionMaxLength) {
            NSLog(@"-------------------------- 超出长度限制 --------------------------");
        } else if (restriction == AFInputRestrictionOptionNumber) {
            NSLog(@"-------------------------- 只能输入纯数字 --------------------------");
        }
    };
    [self.view addSubview:_textField];
    
        
    _textView = [UITextView new];
    _textView.frame = CGRectMake(50, 200, 200, 200);
    _textView.backgroundColor = UIColor.grayColor;
    // 占位文字
    _textView.module.placeholderLb.text = @"请输入吧";
    // 设置 输入字符 最大长度
    _textView.module.maxLenght = 3;
    //展示剩余可输入字符数量的提示
    _textView.module.lenghtTipEnable = YES;
    // 设置 输入的限制类型: 禁止输入中文  禁止输入表情
//    _textView.module.restrictOption = AFInputRestrictionOptionNotChinese | AFInputRestrictionOptionNotEmoji;
    // 超出输入限制 的回调
    _textView.module.beyondRestrictionHandle = ^(AFInputRestrictionOptions restriction) {
        
        if (restriction == AFInputRestrictionOptionMaxLength) {
            NSLog(@"-------------------------- 超出长度限制 --------------------------");
        } else if (restriction == AFInputRestrictionOptionNotChinese) {
            NSLog(@"-------------------------- 禁止输入中文 --------------------------");
            } else if (restriction == AFInputRestrictionOptionNotEmoji) {
            NSLog(@"-------------------------- 禁止输入表情 --------------------------");
        }
    };
    [self.view addSubview:_textView];
}


@end
