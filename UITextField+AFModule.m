//
//  UITextField+AFModule.m
//  AFWorkSpace
//
//  Created by alfie on 2019/11/25.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "UITextField+AFModule.h"
#import "AFTextModule.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation UITextField (AFModule)
static const char *AFTextModuleKey = "AFTextModuleKey";
void AFTextFieldMethodSelector() {}

+ (void)load {

    Method original = class_getInstanceMethod(UITextField.class, @selector(setDelegate:));
    Method swizzl = class_getInstanceMethod(UITextField.class, @selector(afhook_setDelegate:));
    if (class_addMethod(UITextField.class, @selector(setDelegate:), method_getImplementation(swizzl), method_getTypeEncoding(swizzl))) {
        class_replaceMethod(UITextField.class, @selector(afhook_setDelegate:), method_getImplementation(original), method_getTypeEncoding(original));
    } else {
        method_exchangeImplementations(original, swizzl);
    }
}


- (void)afhook_setDelegate:(id<UITextFieldDelegate>)delegate {
    
    if (!delegate) {
        [self afhook_setDelegate:objc_getAssociatedObject(self, AFTextModuleKey) ?: delegate];
        return;
    }
    
    Class swizzleClass = delegate.class;
    if (class_addMethod(swizzleClass, NSSelectorFromString(@"AFTextFieldMethodSelector"), (IMP)AFTextFieldMethodSelector, method_getTypeEncoding(class_getInstanceMethod(swizzleClass, @selector(init))))) {
        
        [self swizzleInstanceMethodWithClass:swizzleClass originalSel:@selector(textField:shouldChangeCharactersInRange:replacementString:) swizzledSel:@selector(afhook_textField:shouldChangeCharactersInRange:replacementString:) addSel:@selector(afadd_textField:shouldChangeCharactersInRange:replacementString:)];
    }
    [self afhook_setDelegate:delegate];
}


- (BOOL)afadd_textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}


- (void)swizzleInstanceMethodWithClass:(Class)swizzleClass originalSel:(SEL)originalSel swizzledSel:(SEL)swizzledSel addSel:(SEL)addSel {
    
    Method originalMethod = class_getInstanceMethod(swizzleClass, originalSel);
    Method swizzleMethod = class_getInstanceMethod(swizzleClass, swizzledSel);
    
    if (class_addMethod(swizzleClass, originalSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
        if (originalMethod) {
            class_replaceMethod(swizzleClass, swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            Method addMethod = class_getInstanceMethod(self.class, addSel);
            class_replaceMethod(swizzleClass, swizzledSel, method_getImplementation(addMethod), method_getTypeEncoding(addMethod));
        }
    }
    else {
        method_exchangeImplementations(class_getInstanceMethod(swizzleClass, originalSel), class_getInstanceMethod(swizzleClass, swizzledSel));
    }
}


- (void)setModule:(AFTextModule *)module {
    objc_setAssociatedObject(self, AFTextModuleKey, module, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (AFTextModule *)module {
    AFTextModule *textModule = objc_getAssociatedObject(self, AFTextModuleKey);
    if (!textModule) {
        textModule = [AFTextModule new];
        textModule.target = self;
        objc_setAssociatedObject(self, AFTextModuleKey, textModule, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (!self.delegate) {
            self.delegate = textModule;
        }
    }
    return textModule;
}


@end
#pragma clang diagnostic pop
