//
//  KVOModule.h
//  AFModule
//
//  Created by alfie on 2019/12/6.
//

#import <Foundation/Foundation.h>


typedef void (^AFKVOChangeBlock)(id observer, id object, NSDictionary<NSString *, id> *change);


@interface KVOModule : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;

// 初始化
+ (instancetype)moduleWithTarget:(id)target;



/** KVO
 *
 * @param object 被观察的对象
 * @param keyPath 被观察对象的keyPath
 * @param options NSKeyValueObservingOptions
 * @param block 回调
 */
- (void)observe:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AFKVOChangeBlock)block;



@end




