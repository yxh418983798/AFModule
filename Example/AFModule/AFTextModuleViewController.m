//
//  AFTextModuleViewController.m
//  AFModule_Example
//
//  Created by alfie on 2019/11/28.
//  Copyright © 2019 yxh418983798. All rights reserved.
//

#import "AFTextModuleViewController.h"
#import "AFTextModule.h"

@interface AFTextModuleViewController () <UITextViewDelegate>

/** textField */
@property (strong, nonatomic) UITextField           *textField;

/** textView */
@property (strong, nonatomic) UITextView            *textView;

@end

@implementation AFTextModuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"测试" style:(UIBarButtonItemStylePlain) target:self action:@selector(rightAction)];
    
    self.view.backgroundColor = UIColor.whiteColor;

//    _textField = [UITextField new];
//    _textField.frame = CGRectMake(50, 100, 200, 50);
//    _textField.backgroundColor = UIColor.lightGrayColor;
//    _textField.textColor = UIColor.blackColor;
////    _textField.module.maxLenght = 3;
//    // 设置 输入的限制类型
//    _textField.module.restrictOption = AFInputRestrictionOptionNoneNullFirstChar | AFInputRestrictionOptionNotSpecialChar | AFInputRestrictionOptionNotNumber;
//    // 超出输入限制 的回调
//    _textField.module.beyondRestrictionHandle = ^(AFInputRestrictionOptions restriction) {
//        if (restriction & AFInputRestrictionOptionMaxLength) {
//            NSLog(@"-------------------------- 超出长度限制 --------------------------");
//        } else if (restriction & AFInputRestrictionOptionOnlyNumber) {
//            NSLog(@"-------------------------- 只能输入纯数字 --------------------------");
//        }
//    };
//    [self.view addSubview:_textField];
//    
//    return;
    
    
    
    UITextField *tf = [UITextField new];
    tf.frame = CGRectMake(50, 100, 200, 50);
    tf.backgroundColor = UIColor.lightGrayColor;
    tf.textColor = UIColor.blackColor;
    tf.module.maxLenght = 10;
    tf.secureTextEntry = NO;
    // 设置 输入的限制类型
//    _textField.module.restrictOption = AFInputRestrictionOptionOnlyNumber;
    // 超出输入限制 的回调
    tf.module.beyondRestrictionHandle = ^(AFInputRestrictionOptions restriction) {
        if (restriction == AFInputRestrictionOptionMaxLength) {
            NSLog(@"-------------------------- 超出长度限制 --------------------------");
        } else if (restriction == AFInputRestrictionOptionOnlyNumber) {
            NSLog(@"-------------------------- 只能输入纯数字 --------------------------");
        }
    };
    [self.view addSubview:tf];
    
    
    _textView = [UITextView new];
    _textView.delegate = self;
    _textView.frame = CGRectMake(50, 200, 300, 100);
    _textView.backgroundColor = UIColor.grayColor;
    _textView.font = [UIFont systemFontOfSize:16];
//    _textView.
    // 占位文字
//    _textView.module.placeholderLb.text = @"请输入吧";
    // 设置 输入字符 最大长度
//    _textView.module.maxLenght = 5;
    //展示剩余可输入字符数量的提示
//    _textView.module.lenghtTipOption = AFLengthTipOptionCanInput;
    // 设置 输入的限制类型: 禁止输入中文  禁止输入表情
//    _textView.module.restrictOption = AFInputRestrictionOptionNotChinese | AFInputRestrictionOptionNotEmoji;
    // 超出输入限制 的回调
//    _textView.module.beyondRestrictionHandle = ^(AFInputRestrictionOptions restriction) {
//
//        if (restriction == AFInputRestrictionOptionMaxLength) {
//            NSLog(@"-------------------------- 超出长度限制 --------------------------");
//        } else if (restriction == AFInputRestrictionOptionNotChinese) {
//            NSLog(@"-------------------------- 禁止输入中文 --------------------------");
//            } else if (restriction == AFInputRestrictionOptionNotEmoji) {
//            NSLog(@"-------------------------- 禁止输入表情 --------------------------");
//        }
//    };
    [self.view addSubview:_textView];
    
    
    
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(50, 50, 300, 100);
    label.attributedText = nil;
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"测试一下" attributes:@{NSForegroundColorAttributeName : UIColor.blackColor}];
    UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"text.gif" ofType:nil]];
    if (image) {
        NSTextAttachment *attachment = NSTextAttachment.new;
        attachment.image = image;
        attachment.bounds = CGRectMake(0, -4, 33, 48);
        NSAttributedString *attrImageStr = [NSAttributedString attributedStringWithAttachment:attachment];
        [attributeString appendAttributedString:attrImageStr];
    }
    label.attributedText = attributeString;
    [self. view addSubview:label];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)rightAction {
    _textField.secureTextEntry = !_textField.secureTextEntry;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"-------------------------- 字数：%ld --------------------------", textView.text.length);
}
@end
