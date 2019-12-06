#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AFTextModule.h"
#import "UITextField+AFModule.h"
#import "UITextView+AFModule.h"
#import "AFTimer.h"
#import "KVOModule.h"
#import "NSObject+KVOModule.h"

FOUNDATION_EXPORT double AFModuleVersionNumber;
FOUNDATION_EXPORT const unsigned char AFModuleVersionString[];

