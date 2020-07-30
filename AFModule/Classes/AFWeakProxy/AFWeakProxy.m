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

- (id)forwardingTargetForSelector:(SEL)selector {
    return _af_target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_af_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_af_target isEqual:object];
}

- (NSUInteger)hash {
    return [_af_target hash];
}

- (Class)superclass {
    return [_af_target superclass];
}

- (Class)class {
    return [_af_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_af_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_af_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_af_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_af_target description];
}

- (NSString *)debugDescription {
    return [_af_target debugDescription];
}

@end



@implementation NSObject (AFWeakProxy)


- (id)af_proxy {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAf_proxy:(id)af_proxy {
    objc_setAssociatedObject(self, @selector(af_proxy), af_proxy, OBJC_ASSOCIATION_ASSIGN);
}

@end
