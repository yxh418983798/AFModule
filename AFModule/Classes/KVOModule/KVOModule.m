//
//  KVOModule.m
//  AFModule
//
//  Created by alfie on 2019/12/6.
//

#import "KVOModule.h"

@interface KVOModule ()

/** target */
@property (weak, nonatomic) id            target;

@end


@implementation KVOModule

+ (instancetype)moduleWithTarget:(id)target {
    KVOModule *KVO = [KVOModule new];
    KVO.target = target;
    return KVO;
}


- (void)observe:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AFKVOChangeBlock)block {
    
    NSAssert(keyPath.length && block && object, @"KVOModule missing required parameters observe:%@ keyPath:%@ block:%p", object, keyPath, block);
    if (!object || !keyPath.length || !block) return;
    
    [object addObserver:self forKeyPath:keyPath options:options context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"-------------------------- MODULE:%@ --------------------------", change[NSKeyValueChangeNewKey]);
}


- (void)dealloc {
    NSLog(@"-------------------------- 释放Module:%@ --------------------------", self);
}


@end
