//
//  UITextView+AFModule.m
//  AFWorkSpace
//
//  Created by alfie on 2019/11/25.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "UITextView+AFModule.h"
#import "AFTextModule.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation UITextView (AFModule)

static const char *AFTextViewModuleKey = "AFTextViewModuleKey";
void AFTextViewMethodSelector() {}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method original = class_getInstanceMethod(UITextView.class, @selector(setDelegate:));
        Method swizzl = class_getInstanceMethod(UITextView.class, @selector(afhook_setDelegate:));
        if (class_addMethod(UITextView.class, @selector(setDelegate:), method_getImplementation(swizzl), method_getTypeEncoding(swizzl))) {
            class_replaceMethod(UITextView.class, @selector(afhook_setDelegate:), method_getImplementation(original), method_getTypeEncoding(original));
        } else {
            method_exchangeImplementations(original, swizzl);
        }
        method_exchangeImplementations(class_getInstanceMethod(UITextView.class, @selector(setText:)), class_getInstanceMethod(UITextView.class, @selector(afhook_setText:)));
    });
}


- (void)afhook_setText:(NSString *)text {
    
    if (self.module.maxLenght > 0) {
        
        __block NSInteger existNum = 0;
        NSMutableString *resultString = NSMutableString.string;
        [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:(NSStringEnumerationByComposedCharacterSequences) usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            existNum++;
            if (existNum <= self.module.maxLenght) {
                [resultString appendString:substring];
            }
        }];
        [self afhook_setText:resultString.copy];
        if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
    } else {
        [self afhook_setText:text];
        if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
    }
}


- (void)afhook_setDelegate:(id<UITextViewDelegate>)delegate {
    
    if (!delegate) {
        [self afhook_setDelegate:objc_getAssociatedObject(self, AFTextViewModuleKey) ?: delegate];
        return;
    }
    Class swizzleClass = delegate.class;
    if (class_addMethod(swizzleClass, NSSelectorFromString(@"AFTextViewMethodSelector"), (IMP)AFTextViewMethodSelector, method_getTypeEncoding(class_getInstanceMethod(swizzleClass, @selector(init))))) {

        [self swizzleInstanceMethodWithClass:swizzleClass originalSel:@selector(textView:shouldChangeTextInRange:replacementText:) swizzledSel:@selector(afhook_textView:shouldChangeTextInRange:replacementText:) addSel:@selector(afadd_textView:shouldChangeTextInRange:replacementText:)];
        
        [self swizzleInstanceMethodWithClass:swizzleClass originalSel:@selector(textViewDidChange:) swizzledSel:@selector(afhook_textViewDidChange:) addSel:@selector(afadd_textViewDidChange:)];

        [self swizzleDelegateMethod:delegate originalSel:@selector(textViewDidBeginEditing:) swizzleSel:@selector(afhook_textViewDidBeginEditing:)];
    }
    [self afhook_setDelegate:delegate];
}


- (BOOL)afadd_textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)afadd_textViewDidChange:(UITextView *)textView {
}


- (void)swizzleInstanceMethodWithClass:(Class)swizzleClass originalSel:(SEL)originalSel swizzledSel:(SEL)swizzledSel addSel:(SEL)addSel {
    
    Method originalMethod = class_getInstanceMethod(swizzleClass, originalSel);
    Method swizzleMethod = class_getInstanceMethod(swizzleClass, swizzledSel);

    if (!class_addMethod(swizzleClass, originalSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
        if (class_addMethod(swizzleClass, NSSelectorFromString([NSString stringWithFormat:@"afhook_%@_%@", NSStringFromClass(swizzleClass), NSStringFromSelector(originalSel)]), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))) {
            class_replaceMethod(swizzleClass, originalSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
        }
    }
}

static void AFModuleAddIMPSelector() {}
- (void)swizzleDelegateMethod:(id)delegate originalSel:(SEL)originalSel swizzleSel:(SEL)swizzleSel {
    Class delegateClass = [delegate class];
    Method swizzleMethod = class_getInstanceMethod(delegateClass, swizzleSel);
    if (![delegate respondsToSelector:originalSel]) {
        class_addMethod(delegateClass, originalSel, (IMP)AFModuleAddIMPSelector, method_getTypeEncoding(class_getInstanceMethod(delegateClass, @selector(init))));
    }
    if (class_addMethod(delegateClass, swizzleSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
        // 添加成功，进行交换
        Method originMethod = class_getInstanceMethod(delegateClass, originalSel);
        swizzleMethod = class_getInstanceMethod(delegateClass, swizzleSel);
        method_exchangeImplementations(originMethod, swizzleMethod);
    }
}

- (void)setModule:(AFTextViewModule *)module {
    objc_setAssociatedObject(self, AFTextViewModuleKey, module, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (AFTextViewModule *)module {
    AFTextViewModule *textViewModule = objc_getAssociatedObject(self, AFTextViewModuleKey);
    if (!textViewModule) {
        textViewModule = [AFTextViewModule new];
        textViewModule.target = self;
        objc_setAssociatedObject(self, AFTextViewModuleKey, textViewModule, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (!self.delegate) {
            self.delegate = textViewModule;
        }
    }
    return textViewModule;
}

@end

#pragma clang diagnostic pop
