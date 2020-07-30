//
//  AFWeakProxy.h
//  AFModule
//
//  Created by alfie on 2020/7/30.
//

#import <Foundation/Foundation.h>

@interface AFWeakProxy : NSObject

@property (nonatomic, weak, readonly) id af_target;

/** 标识 */
@property (nonatomic, strong) id      af_identity;

+ (instancetype)proxyWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target identity:(id)identity;

@end


@interface NSObject (AFWeakProxy)

@property (nonatomic, weak) id            af_proxy;
//- (id)mw_proxy;

@end
