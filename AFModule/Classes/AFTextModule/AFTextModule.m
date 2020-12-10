//
//  AFTextModule.m
//  AFWorkSpace
//
//  Created by alfie on 2019/11/25.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "AFTextModule.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (AFTextModule)

- (NSInteger)displayLengthWithString:(NSString *)string {
    if (!string) return 0;
    
    __block NSInteger length = 0;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:(NSStringEnumerationByComposedCharacterSequences) usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        length++;
    }];
    return length;
}


- (BOOL)afperform_textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"afhook_%@_textField:shouldChangeCharactersInRange:replacementString:", NSStringFromClass(self.class)]);
    if ([self respondsToSelector:sel]) {
        return ((BOOL (*)(id, SEL, id, NSRange, NSString *))objc_msgSend)(self, sel, textField, range, string);
    } else {
        return YES;
    }
}


- (BOOL)afhook_textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if ([string isEqualToString:@""]) {
        return [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
        return YES;
    }
    
    if ([string isEqualToString:@"\n"]) {
        [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
        return NO;
    }
    
    if (textField.module.restrictOption & AFInputRestrictionOptionNoneNullFirstChar) {
        if (!textField.text.length && [string isEqualToString:@" "]) {
            if (textField.module.beyondRestrictionHandle) {
                textField.module.beyondRestrictionHandle(AFInputRestrictionOptionNoneNullFirstChar);
            }
            [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
            return NO;
        }
    }
    
    if (textField.module.restrictOption & AFInputRestrictionOptionNumber) {
        NSString *regex = @"[0-9]*";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![predicate evaluateWithObject:string]) {
            if (textField.module.beyondRestrictionHandle) {
                textField.module.beyondRestrictionHandle(AFInputRestrictionOptionNumber);
            }
            [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
            return NO;
        }
    }
    
    if (textField.module.restrictOption & AFInputRestrictionOptionOnlyChinese) {
        NSString *regex = @"(^[\u4e00-\u9fa5]+$)";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![predicate evaluateWithObject:string]) {
            if (textField.module.beyondRestrictionHandle) {
                textField.module.beyondRestrictionHandle(AFInputRestrictionOptionOnlyChinese);
            }
            [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
            return NO;
        }
    }
    
    else if (textField.module.restrictOption & AFInputRestrictionOptionNotChinese) {
        NSString *regex = @"(^[\u4e00-\u9fa5]+$)";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([predicate evaluateWithObject:string]) {
            if (textField.module.beyondRestrictionHandle) {
                textField.module.beyondRestrictionHandle(AFInputRestrictionOptionNotChinese);
            }
            [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
            return NO;
        }
    }
    
    if (textField.module.restrictOption & AFInputRestrictionOptionNotSpecialChar) {
        NSString *regex = @"^[A-Za-z0-9\\u4e00-\u9fa5]+$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![predicate evaluateWithObject:string]) {
            if (textField.module.beyondRestrictionHandle) {
                textField.module.beyondRestrictionHandle(AFInputRestrictionOptionNotSpecialChar);
            }
            [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
            return NO;
        }
    }
    
    if (textField.module.restrictOption & AFInputRestrictionOptionNotSpace) {
        if ([string isEqualToString:@" "]) {
            if (textField.module.beyondRestrictionHandle) {
                textField.module.beyondRestrictionHandle(AFInputRestrictionOptionNotSpace);
            }
            [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
            return NO;
        }
    }
    
    if (textField.module.restrictOption & AFInputRestrictionOptionNotEmoji) {
         __block BOOL hasEomji = NO;
        [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            const unichar hs = [substring characterAtIndex:0];
            if (0xd800 <= hs && hs <= 0xdbff) {
               if (substring.length > 1) {
                   const unichar ls = [substring characterAtIndex:1];
                   const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                  if (0x1d000 <= uc && uc <= 0x1f77f) {
                     hasEomji = YES;
                  }
              }
            } else if (substring.length > 1) {
              const unichar ls = [substring characterAtIndex:1];
              if (ls == 0x20e3 || ls == 0xfe0f) {
                  hasEomji = YES;
              }
            } else {
              if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                  hasEomji = YES;
              } else if (0x2B05 <= hs && hs <= 0x2b07) {
                  hasEomji = YES;
              } else if (0x2934 <= hs && hs <= 0x2935) {
                  hasEomji = YES;
              } else if (0x3297 <= hs && hs <= 0x3299) {
                  hasEomji = YES;
              } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                  hasEomji = YES;
              }
            }
        }];
        if (hasEomji) {
            if (textField.module.beyondRestrictionHandle) {
                textField.module.beyondRestrictionHandle(AFInputRestrictionOptionNotEmoji);
            }
            [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
            return NO;
        }
    }
 
    
    NSInteger maxLenght = textField.module.maxLenght;
    if (maxLenght > 0) {
        UITextRange *selectedRang = [textField markedTextRange];
        UITextPosition *pos = [textField positionFromPosition:selectedRang.start offset:0];
        if (selectedRang && pos) {
            NSInteger startOffset = [textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedRang.start];
            if (startOffset < maxLenght) {
                return [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
            } else {
                if (textField.module.beyondRestrictionHandle) {
                    textField.module.beyondRestrictionHandle(AFInputRestrictionOptionMaxLength);
                }
                [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
                return NO;
            }
        }

        NSString *comcatStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSInteger canInputLength = maxLenght - [self displayLengthWithString:comcatStr];
        if (canInputLength >= 0) {
            return [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
        } else {
            NSInteger length = [self displayLengthWithString:string] + canInputLength;
            NSRange rang = {0, MAX(length, 0)};
            if (range.length > 0) {
                NSString *subString = [string substringWithRange:rang];
                textField.text = [textField.text stringByReplacingCharactersInRange:rang withString:subString];
            }
            if (textField.module.beyondRestrictionHandle) {
                textField.module.beyondRestrictionHandle(AFInputRestrictionOptionMaxLength);
            }
            [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
            return NO;
        }
    }
    return [self afperform_textField:textField shouldChangeCharactersInRange:range replacementString:string];
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if (textField.module.maxLenght > 0) {
        UITextRange *selectedRange = textField.markedTextRange;
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (selectedRange && position) return;
        NSString *text = textField.text;
        NSInteger existNum = [self displayLengthWithString:text];
        if (existNum > textField.module.maxLenght) {
            textField.text = [text substringToIndex:textField.module.maxLenght];
        }
    }
}


#pragma mark - UITextView
- (BOOL)afperform_textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"afhook_%@_textView:shouldChangeTextInRange:replacementText:", NSStringFromClass(self.class)]);
    if ([self respondsToSelector:sel]) {
        return ((BOOL (*)(id, SEL, id, NSRange, NSString *))objc_msgSend)(self, sel, textView, range, text);
    } else {
        return YES;
    }
}

- (void)afhook_textViewDidChange:(UITextView *)textView {
    
    textView.module.placeholderLb.hidden = textView.text.length;
    if ([self respondsToSelector:@selector(textViewDidChange:)]) {
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"afhook_%@_textViewDidChange:", NSStringFromClass(self.class)]);
        if ([self respondsToSelector:sel]) {
            ((void (*)(id, SEL, id))objc_msgSend)(self, NSSelectorFromString([NSString stringWithFormat:@"afhook_%@_textViewDidChange:", NSStringFromClass(self.class)]), textView);
        }
    }
    if (textView.module.maxLenght > 0) {

        UITextRange *selectedRange = textView.markedTextRange;
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (selectedRange && position) return;
        NSString *text = textView.text;
        NSInteger existNum = [self displayLengthWithString:text];
        if (existNum > textView.module.maxLenght) {
            textView.text = [text substringToIndex:textView.module.maxLenght];
        }
        
        //更新字符长度
        if (textView.module.lenghtTipEnable) {
            textView.module.lenghtTipLb.text = [NSString stringWithFormat:@"%d/%zi", MAX((int)(textView.module.maxLenght - existNum), 0), textView.module.maxLenght];
        }
    }
}

- (BOOL)afhook_textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@""]) {
        return [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    if (textView.module.restrictOption & AFInputRestrictionOptionNoneNullFirstChar) {
        if (!textView.text.length && ([text isEqualToString:@" "] || [text isEqualToString:@"\n"])) {
            if (textView.module.beyondRestrictionHandle) {
                textView.module.beyondRestrictionHandle(AFInputRestrictionOptionNoneNullFirstChar);
            }
            [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
            return NO;
        }
    }
    
    if (textView.module.restrictOption & AFInputRestrictionOptionNumber) {
        NSString *regex = @"[0-9]*";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![predicate evaluateWithObject:text]) {
            if (textView.module.beyondRestrictionHandle) {
                textView.module.beyondRestrictionHandle(AFInputRestrictionOptionNumber);
            }
            [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
            return NO;
        }
    }
    
    if (textView.module.restrictOption & AFInputRestrictionOptionOnlyChinese) {
        NSString *regex = @"(^[\u4e00-\u9fa5]+$)";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![predicate evaluateWithObject:text]) {
            if (textView.module.beyondRestrictionHandle) {
                textView.module.beyondRestrictionHandle(AFInputRestrictionOptionOnlyChinese);
            }
            [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
            return NO;
        }
    }
    
    else if (textView.module.restrictOption & AFInputRestrictionOptionNotChinese) {
        for (int i = 0; i < text.length; i++) {
            int character = [text characterAtIndex:i];
            if( character > 0x4e00 && character < 0x9fff){
                if (textView.module.beyondRestrictionHandle) {
                    textView.module.beyondRestrictionHandle(AFInputRestrictionOptionNotChinese);
                }
                [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
                return NO;
            }
        }
    }
    
    if (textView.module.restrictOption & AFInputRestrictionOptionNotSpecialChar) {
        NSString *regex = @"^[A-Za-z0-9\\u4e00-\u9fa5]+$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![predicate evaluateWithObject:text]) {
            if (textView.module.beyondRestrictionHandle) {
                textView.module.beyondRestrictionHandle(AFInputRestrictionOptionNotSpecialChar);
            }
            [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
            return NO;
        }
    }
    
    if (textView.module.restrictOption & AFInputRestrictionOptionNotSpace) {
        if (textView.module.beyondRestrictionHandle) {
            textView.module.beyondRestrictionHandle(AFInputRestrictionOptionNotSpace);
        }
        if ([text isEqualToString:@" "]) {
            [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
            return NO;
        }
    }
    
    if (textView.module.restrictOption & AFInputRestrictionOptionNotEmoji) {
         __block BOOL hasEomji = NO;
        [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            const unichar hs = [substring characterAtIndex:0];
            if (0xd800 <= hs && hs <= 0xdbff) {
               if (substring.length > 1) {
                   const unichar ls = [substring characterAtIndex:1];
                   const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                  if (0x1d000 <= uc && uc <= 0x1f77f) {
                     hasEomji = YES;
                  }
              }
            } else if (substring.length > 1) {
              const unichar ls = [substring characterAtIndex:1];
              if (ls == 0x20e3 || ls == 0xfe0f) {
                  hasEomji = YES;
              }
            } else {
              if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                  hasEomji = YES;
              } else if (0x2B05 <= hs && hs <= 0x2b07) {
                  hasEomji = YES;
              } else if (0x2934 <= hs && hs <= 0x2935) {
                  hasEomji = YES;
              } else if (0x3297 <= hs && hs <= 0x3299) {
                  hasEomji = YES;
              } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                  hasEomji = YES;
              }
            }
        }];
        if (hasEomji) {
            if (textView.module.beyondRestrictionHandle) {
                textView.module.beyondRestrictionHandle(AFInputRestrictionOptionNotEmoji);
            }
            [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
            return NO;
        }
    }
 
    
    NSInteger maxLenght = textView.module.maxLenght;
    if (maxLenght > 0) {
        UITextRange *selectedRang = [textView markedTextRange];
        UITextPosition *pos = [textView positionFromPosition:selectedRang.start offset:0];
        if (selectedRang && pos) {
            NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRang.start];
            if (startOffset < maxLenght) {
                return [self afhook_textView:textView shouldChangeTextInRange:range replacementText:text];
            } else {
                if (textView.module.beyondRestrictionHandle) {
                    textView.module.beyondRestrictionHandle(AFInputRestrictionOptionMaxLength);
                }
                [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
                return NO;
            }
        }

        NSString *comcatStr = [textView.text stringByReplacingCharactersInRange:range withString:text];
        NSInteger canInputLength = maxLenght - [self displayLengthWithString:comcatStr];
        if (canInputLength >= 0) {
            return [self afhook_textView:textView shouldChangeTextInRange:range replacementText:text];
        } else {
            NSInteger length = [self displayLengthWithString:text] + canInputLength;
            NSRange rang = {0, MAX(length, 0)};
            if (range.length > 0) {
                NSString *subString = [text substringWithRange:rang];
                textView.text = [textView.text stringByReplacingCharactersInRange:rang withString:subString];
            }
            if (textView.module.beyondRestrictionHandle) {
                textView.module.beyondRestrictionHandle(AFInputRestrictionOptionMaxLength);
            }
            [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
            return NO;
        }
    }
    return [self afperform_textView:textView shouldChangeTextInRange:range replacementText:text];
}

@end




@implementation AFTextModule

- (UILabel *)placeholderLb {
    if (@available(iOS 13.0, *)) {
        return [self placeholderLabelForView:self.target];
    } else {
        return [self valueForKey:@"_placeholderLabel"];
    }
}

- (UILabel *)placeholderLabelForView:(UIView *)superView {
    if (superView.subviews.count) {
        for (UIView *subView in superView.subviews) {
            if ([subView isKindOfClass:[UILabel class]] && [NSStringFromClass(subView.class) containsString:@"placeholder"]) {
                return (UILabel *)subView;
            } else {
                UILabel *placeholderLabel = [self placeholderLabelForView:subView];
                if (placeholderLabel) return placeholderLabel;
                continue;
            }
        }
    }
    return nil;
}

@end



@implementation AFTextViewModule

- (UILabel *)placeholderLb {
    if (!_placeholderLb) {
        _placeholderLb = [UILabel new];
        _placeholderLb.textColor = [UIColor colorWithRed:157 green:164 blue:179 alpha:1];
        _placeholderLb.font = [UIFont systemFontOfSize:14];
        _placeholderLb.numberOfLines = 0;
        _placeholderLb.translatesAutoresizingMaskIntoConstraints = NO;
        if (self.target) {
            [self.target addSubview:_placeholderLb];
            [self.target addConstraint:[NSLayoutConstraint constraintWithItem:_placeholderLb attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self.target attribute:(NSLayoutAttributeLeft) multiplier:1 constant:10]];
            [self.target addConstraint:[NSLayoutConstraint constraintWithItem:_placeholderLb attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:self.target attribute:(NSLayoutAttributeWidth) multiplier:1 constant:-15]];
            [self.target addConstraint:[NSLayoutConstraint constraintWithItem:_placeholderLb attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.target attribute:(NSLayoutAttributeTop) multiplier:1 constant:5]];
        }
    }
    return _placeholderLb;
}

- (UILabel *)lenghtTipLb {
    if (!_lenghtTipLb) {
        _lenghtTipLb = [[UILabel alloc] initWithFrame:(CGRectMake(5, self.target.frame.size.height - 20, self.target.frame.size.width - 10, 20))];
        _lenghtTipLb.textColor = [UIColor colorWithRed:157 green:164 blue:179 alpha:1];
        _lenghtTipLb.font = [UIFont systemFontOfSize:14];
        _lenghtTipLb.textAlignment = NSTextAlignmentRight;
        [self.target addSubview:_lenghtTipLb];
    }
    return _lenghtTipLb;
}

- (void)setLenghtTipEnable:(BOOL)lenghtTipEnable {
    _lenghtTipEnable = lenghtTipEnable;
    if (lenghtTipEnable) {
        [self.target addSubview:self.lenghtTipLb];
        if (self.maxLenght > 0) {
            self.lenghtTipLb.text = [NSString stringWithFormat:@"%d/%zi", MAX((int)(self.maxLenght - [self displayLengthWithString:[(UITextView *)self.target text]]), 0), self.maxLenght];
        }
    } else {
        if (_lenghtTipLb.superview) [_lenghtTipLb removeFromSuperview];
    }
}

- (void)setMaxLenght:(NSInteger)maxLenght {
    [super setMaxLenght:maxLenght];
    if (maxLenght > 0 && self.lenghtTipEnable) {
        self.lenghtTipLb.text = [NSString stringWithFormat:@"%d/%zi", MAX((int)(self.maxLenght - [self displayLengthWithString:[(UITextView *)self.target text]]), 0), self.maxLenght];
    }
}

@end
