//
//  AFTextModule.h
//  AFWorkSpace
//
//  Created by alfie on 2019/11/25.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITextField+AFModule.h"
#import "UITextView+AFModule.h"


#pragma mark - 输入限制
typedef NS_OPTIONS(NSInteger, AFInputRestrictionOptions) {
    AFInputRestrictionOptionNone              = 1 << 0,   // 没有限制
    AFInputRestrictionOptionNoneNullFirstChar = 1 << 1,   // 首字符不能为空
    AFInputRestrictionOptionNumber            = 1 << 2,   // 输入纯数字
    AFInputRestrictionOptionOnlyChinese       = 1 << 3,   // 输入纯中文
    AFInputRestrictionOptionNotChinese        = 1 << 4,   // 禁止输入中文
    AFInputRestrictionOptionNotEmoji          = 1 << 5,   // 禁止输入表情
    AFInputRestrictionOptionNotSpecialChar    = 1 << 6,   // 禁止特殊字符（除了英文、数字、中文意外的字符）
    AFInputRestrictionOptionNotSpace          = 1 << 7,   // 禁止输入空格

    AFInputRestrictionOptionMaxLength         = 1 << 10,  // 长度限制，不需要设置枚举，只要设置maxLenght大于0即可
};

typedef void(^BeyondRestrictionHandle)(AFInputRestrictionOptions restriction);


@interface AFTextModule : NSObject <UITextFieldDelegate> {
    UILabel *_placeholderLb;
}

/** target -- kindOf UITextField or UITextView */
@property (weak, nonatomic) UIView                      *target;

/** placeholderLabel */
@property (nonatomic, strong, readonly) UILabel         *placeholderLb;

/** 输入限制 */
@property (assign, nonatomic) AFInputRestrictionOptions restrictOption;

/** 限制输入字符的最大长度 */
@property (assign, nonatomic) NSInteger                 maxLenght;

/** 超出输入限制范围的回调 */
@property (copy, nonatomic) BeyondRestrictionHandle     beyondRestrictionHandle;

@end



@interface AFTextViewModule : AFTextModule <UITextViewDelegate> {
    UILabel *_lenghtTipLb;
}

/** 剩余字符提示 */
@property (nonatomic, strong, readonly) UILabel         *lenghtTipLb;

/** 是否展示字符提示，默认NO */
@property (assign, nonatomic) BOOL                      lenghtTipEnable;

@end



@interface NSObject (AFTextModule)

@end
