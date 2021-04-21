//
//  AFGifTextViewController.m
//  AFModule_Example
//
//  Created by alfie on 2021/2/20.
//  Copyright © 2021 yxh418983798. All rights reserved.
//

#import "AFGifTextViewController.h"
#import "AFLabel.h"
#import <YYImage/YYImage.h>
#import "YYText.h"

@interface AFGifTextViewController ()

/** label */
@property (nonatomic, strong) AFLabel            *titleLb;

/** te */
@property (nonatomic, strong) YYTextView            *textView;

@end

@implementation AFGifTextViewController

static NSString *pattern = @"[]";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    _titleLb = [AFLabel new];
    _titleLb.backgroundColor = UIColor.grayColor;
    _titleLb.frame = CGRectMake(100, 100, 300, 300);
    [self.view addSubview:_titleLb];
    
//    _textView = YYTextView.new;
//    _textView.frame = CGRectMake(100, 400, 300, 300);
//    [self.view addSubview:_textView];

    [self attachData:nil];
}


//绑定数据
- (void)attachData:(id)data {
    
//    _titleLb.text = @"asdasd";
    
    NSString *title = [NSString stringWithFormat:@"测试gif[大拇指动态][肌肉]"];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:title];
    YYImage *image = [YYImage imageWithData:[NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"肌肉" ofType:@".gif"]]];
    if (image) {
        NSTextAttachment *attachment = [NSTextAttachment new];
        attachment.image = image;
        attachment.bounds = CGRectMake(0, -4, 30, 30);
        NSAttributedString *attrImageStr = [NSAttributedString attributedStringWithAttachment:attachment];
        [str appendAttributedString:attrImageStr];
        _titleLb.attributedText = str;
//        _textView.attributedText = str;
    }
    
    
    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
//    NSArray *resultArr = [regex matchesInString:title options:0 range:NSMakeRange(0, title.length)];
//    for (NSInteger i = resultArr.count - 1; i >= 0; i --) {
//        NSTextCheckingResult *result = resultArr[i];
//        NSString *chs = [title substringWithRange:NSMakeRange(result.range.location+2, result.range.length-3)];
//        UIImage *image = [UIImage imageNamed:chs];
//        if (image) {
//            NSTextAttachment *attachment = [NSTextAttachment new];
//            attachment.image = image;
//            attachment.bounds = bounds;
//            NSAttributedString *attrImageStr = [NSAttributedString attributedStringWithAttachment:attachment];
//            [attributeString replaceCharactersInRange:result.range withAttributedString:attrImageStr];
//        }
//    }
        
}

//
//- (NSMutableAttributedString *)imageAttributeStringWithFont:(UIFont *)font {
//    return [self imageAttributeStringWithBounds:CGRectMake(0, -4, font.lineHeight, font.lineHeight)];
//}
//
//
//- (NSMutableAttributedString *)imageAttributeStringWithBounds:(CGRect)bounds {
//    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
//
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
//    if (!regex) {
//        return attributeString;
//    }
//
//    NSArray *resultArr = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
//    for (NSInteger i = resultArr.count - 1; i >= 0; i --) {
//        NSTextCheckingResult *result = resultArr[i];
//        NSString *chs = [self substringWithRange:NSMakeRange(result.range.location+2, result.range.length-3)];
//        UIImage *image = [UIImage imageNamed:chs];
//        if (image) {
//            NSTextAttachment *attachment = [NSTextAttachment new];
//            attachment.image = image;
//            attachment.bounds = bounds;
//            NSAttributedString *attrImageStr = [NSAttributedString attributedStringWithAttachment:attachment];
//            [attributeString replaceCharactersInRange:result.range withAttributedString:attrImageStr];
//        }
//    }
//    return attributeString;
//}



@end
