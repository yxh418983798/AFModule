//
//  AFDeviceObserver.h
//  AFModule
//
//  Created by alfie on 2020/7/30.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CoreTelephonyDefines.h>

@protocol AFDeviceDelegate <NSObject>

@optional;

/// 静音状态改变的回调
- (void)deviceDidChangeMuteStatus:(BOOL)isMute;

/// 来电状态改变的回调
- (void)deviceDidChangeCallStatu:(NSString *)callStatus;

@end


@interface AFDeviceObserver : NSObject

/** 是否使用外置的音频输出 */
@property (class) BOOL usingAudioPort;

/** 是否在系统通话中 */
@property (class) BOOL hasCall;

/// 获取设备当前是否静音，只会检测一次，如果需要实时监听状态，需要添加代理并实现代理方法
+ (void)getMuteStatus:(void (^)(BOOL isMute))completion;

/// 添加设备静音的监听者，添加后，AFDeviceObserver会实时检测静音状态，直到监听者移除监听或监听者被释放
+ (void)addMuteObserver:(id <AFDeviceDelegate>)observer;

/// 手动移除设备静音的监听者，不移除也不会造成内存泄露
+ (void)removeMuteObserver:(id <AFDeviceDelegate>)observer;

/// 添加设备来电的监听者
+ (void)addCallObserver:(id <AFDeviceDelegate>)observer;

/// 手动移除设备来电的监听者，不移除也不会造成内存泄露
+ (void)removeCallObserver:(id <AFDeviceDelegate>)observer;

@end
