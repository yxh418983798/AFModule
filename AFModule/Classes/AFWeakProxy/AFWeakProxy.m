//
//  AFWeakProxy.m
//  AFModule
//
//  Created by alfie on 2020/7/30.
//

#import "AFWeakProxy.h"
#import <objc/runtime.h>

@implementation AFWeakProxy

- (instancetype)initWithTarget:(id)target identity:(id)identity {
    _af_target = target;
    _af_identity = identity;
    objc_setAssociatedObject(target, @selector(af_proxy), self, OBJC_ASSOCIATION_ASSIGN);
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[AFWeakProxy alloc] initWithTarget:target identity:nil];
}

+ (instancetype)proxyWithTarget:(id)target identity:(id)identity {
    return [[AFWeakProxy alloc] initWithTarget:target identity:identity];
}


@end



@implementation NSObject (AFWeakProxy)


- (AFWeakProxy *)af_proxy {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAf_proxy:(id)af_proxy {
    objc_setAssociatedObject(self, @selector(af_proxy), af_proxy, OBJC_ASSOCIATION_ASSIGN);
}

@end
