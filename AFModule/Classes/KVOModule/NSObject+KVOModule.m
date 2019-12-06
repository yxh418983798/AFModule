//
//  NSObject+KVOModule.m
//  AFModule
//
//  Created by alfie on 2019/12/6.
//

#import "NSObject+KVOModule.h"
#import "KVOModule.h"
#import <objc/message.h>


static void *AFKVOModuleKey = &AFKVOModuleKey;

@implementation NSObject (KVOModule)

- (void)setKVO:(KVOModule *)KVO {
    objc_setAssociatedObject(self, AFKVOModuleKey, KVO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (KVOModule *)KVO {
    KVOModule *module = objc_getAssociatedObject(self, AFKVOModuleKey);
    if (!module) {
      module = [KVOModule moduleWithTarget:self];
      objc_setAssociatedObject(self, AFKVOModuleKey, module, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return module;
}

@end

