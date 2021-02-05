//
//  AFDeviceObserver.m
//  AFModule
//
//  Created by alfie on 2020/7/30.
//

#import "AFDeviceObserver.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <AFModule/AFWeakProxy.h>
#import <AFModule/AFTimer.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
 
typedef void(^ObserverCompletion)(BOOL isMute);

@interface AFDeviceObserver () <AFDeviceDelegate>

/** 开始计时的时间 */
@property (nonatomic, strong) NSDate            *beginDate;

/** 定时器 */
@property (nonatomic, strong) AFTimer           *timer;

/** 是否处于静音的监听中 */
@property (nonatomic, assign) BOOL              isMuteObserving;

/** 播放器，预播放音频 */
@property (nonatomic, strong) AVAudioPlayer     *player;

/** block */
@property (nonatomic, copy) ObserverCompletion  muteCompletion;

/** 监听来电回调 */
@property(nonatomic, strong) CTCallCenter       *callCenter;

@end


@implementation AFDeviceObserver
static NSTimeInterval MuteTimerInterval = 0.001; // 定时器的间隔

#pragma mark - 生命周期
+ (void)initialize {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(aVAudioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
}


#pragma mark - 单例
+ (instancetype)shareObserver {
    static AFDeviceObserver *observer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        observer = AFDeviceObserver.new;
//        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:self.class] URLForResource:@"AFModule" withExtension:@"bundle"]];
        observer.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"detection.aiff" withExtension:nil] error:nil];
        [observer.player prepareToPlay];
    });
    return observer;
}


#pragma mark - Getter
+ (NSMutableArray *)muteObservers {
    static NSMutableArray *_observers;
    if (!_observers) {
        _observers = NSMutableArray.array;
    }
    return _observers;
}

+ (NSMutableArray <AFWeakProxy *> *)callObservers {
    static NSMutableArray <AFWeakProxy *> *_observers;
    if (!_observers) {
        _observers = NSMutableArray.array;
    }
    return _observers;
}

- (CTCallCenter *)callCenter {
    if (!_callCenter) {
        _callCenter = [[CTCallCenter alloc] init];
    }
    return _callCenter;
}


#pragma mark - 获取手机当前是否静音，只会调用一次
+ (void)getMuteStatus:(void (^)(BOOL))completion {
    AFDeviceObserver *observer = AFDeviceObserver.new;
    [observer setMuteCompletion:completion];
    [self addMuteObserver:observer];
}


#pragma mark - 添加静音监听者
+ (void)addMuteObserver:(NSObject <AFDeviceDelegate> *)observer {
    if (!observer || [self.muteObservers containsObject:observer]) return;
    if ([observer isKindOfClass:AFDeviceObserver.class]) {
        [self.muteObservers addObject:observer];
    } else {
        for (AFWeakProxy *muteObserver in self.muteObservers) {
            if ([muteObserver isKindOfClass:AFWeakProxy.class] && muteObserver.af_target == observer) {
                return;
            }
        }
        [self.muteObservers addObject:[AFWeakProxy proxyWithTarget:observer]];
    }
    [AFDeviceObserver startMuteObserve];
}


#pragma mark - 移除静音监听者
+ (void)removeMuteObserver:(NSObject *)observer {
//    if (!self.muteObservers.count) return;
    if (!observer) {
        return;
    }
    for (AFWeakProxy *muteObserver in self.muteObservers) {
        if (muteObserver == observer) {
            [self.muteObservers removeObject:muteObserver];
            return;
        }
        if ([muteObserver isKindOfClass:AFWeakProxy.class] && muteObserver.af_target == observer) {
            [self.muteObservers removeObject:muteObserver];
            return;
        }
    }
}

#pragma mark - 开始监听静音状态
static NSTimeInterval _beginDate;
+ (void)startMuteObserve {
    if (!AFDeviceObserver.muteObservers.count) return;
    if (AFDeviceObserver.shareObserver.isMuteObserving) return;
    AFDeviceObserver.shareObserver.isMuteObserving = YES;
    [AFDeviceObserver checkMuteStatus];
}


#pragma mark - 检查设备静音状态
+ (void)checkMuteStatus {
//    NSLog(@"-------------------------- 开始检测 --------------------------");
    _beginDate = NSDate.date.timeIntervalSince1970;
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("detection"), CFSTR("aiff"), NULL);
    SystemSoundID systemSoundID;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &systemSoundID);
    AudioServicesAddSystemSoundCompletion(systemSoundID, NULL, NULL, soundCompletion, NULL);
    AudioServicesPlaySystemSound(systemSoundID);
}

// 监听回调
static void soundCompletion(SystemSoundID systemSoundID, void *inClientData) {
    
    AudioServicesRemoveSystemSoundCompletion(systemSoundID);
    BOOL isMute = (NSDate.date.timeIntervalSince1970 - _beginDate) < 0.1;
//    NSLog(@"-------------------------- 静音回调：%d %g --------------------------", isMute, NSDate.date.timeIntervalSince1970 - _beginDate);
    for (int i = (int)AFDeviceObserver.muteObservers.count - 1; i >= 0; i--) {
        AFWeakProxy *proxy = AFDeviceObserver.muteObservers[i];
        if ([proxy isKindOfClass:AFDeviceObserver.class]) {
            // 一次性回调
            AFDeviceObserver *observer = (AFDeviceObserver *)proxy;
            [observer deviceDidChangeMuteStatus:isMute];
            [AFDeviceObserver removeMuteObserver:observer];
        } else if ([proxy isKindOfClass:AFWeakProxy.class]) {
            // 持续监听
            NSNumber *isFirst = objc_getAssociatedObject(proxy, "isFirst");
            if (!isFirst || isFirst.boolValue != isMute) {
                objc_setAssociatedObject(proxy, "isFirst", @(isMute), OBJC_ASSOCIATION_RETAIN);
                // 首次检测 或 有改变状态，走代理方法
                id target = proxy.af_target;
                if (target) {
                    if ([target respondsToSelector:@selector(deviceDidChangeMuteStatus:)]) {
                        [target deviceDidChangeMuteStatus:isMute];
                    }
                } else {
                    [AFDeviceObserver removeMuteObserver:proxy];
                }
            }
        } else {
            [AFDeviceObserver removeMuteObserver:proxy];
        }
    }
    if (AFDeviceObserver.muteObservers.count) {
        [AFDeviceObserver checkMuteStatus];
    } else {
        [AFDeviceObserver stopMuteObserve];
    }
}


#pragma mark - 停止静音监听
+ (void)stopMuteObserve {

    if (AFDeviceObserver.muteObservers.count) {
        [AFDeviceObserver.muteObservers removeAllObjects];
    }
    [AFDeviceObserver.shareObserver.timer invalidate];
    AFDeviceObserver.shareObserver.isMuteObserving = NO;
}


#pragma mark - 添加设备来电的监听者
+ (void)addCallObserver:(NSObject <AFDeviceDelegate> *)observer {
    if (observer.af_proxy && [self.callObservers containsObject:observer.af_proxy]) return;
    [self.callObservers addObject:[AFWeakProxy proxyWithTarget:observer]];
    [AFDeviceObserver startCallObserve];
}


#pragma mark - 移除设备来电的监听者
+ (void)removeCallObserver:(NSObject <AFDeviceDelegate> *)observer {
    if ([self.callObservers containsObject:observer.af_proxy]) {
        [self.callObservers removeObject:observer.af_proxy];
    }
    if (!AFDeviceObserver.callObservers.count) {
        AFDeviceObserver.shareObserver->_callCenter = nil;
    }
}


#pragma mark - 是否在系统通话中
static NSNumber *_hasCall;
+ (BOOL)hasCall {
    if (!_hasCall) {
        _hasCall = AFDeviceObserver.shareObserver.callCenter.currentCalls ? @(YES) : @(NO);
    }
    return _hasCall.boolValue;
}


#pragma mark - 开始监听设备来电
+ (void)startCallObserve {
    AFDeviceObserver.shareObserver.callCenter.callEventHandler = ^(CTCall *call) {
        if (call.callState == CTCallStateDisconnected) {
            NSLog(@"电话结束或挂断电话");
            _hasCall = @(NO);
        } else if (call.callState == CTCallStateConnected) {
            NSLog(@"电话接通");
            _hasCall = @(YES);
        } else if(call.callState == CTCallStateIncoming) {
            NSLog(@"来电话");
            _hasCall = @(YES);
        } else if (call.callState ==CTCallStateDialing) {
            NSLog(@"拨号打电话(在应用内调用打电话功能)");
            _hasCall = @(YES);
        }
        
        for (int i = (int)AFDeviceObserver.callObservers.count - 1; i >= 0; i--) {
            AFWeakProxy *proxy = AFDeviceObserver.callObservers[i];
            id target = proxy.af_target;
            if (target) {
                if ([target respondsToSelector:@selector(deviceDidChangeCallStatu:)]) {
                    [target deviceDidChangeCallStatu:call.callState];
                }
            } else {
                [AFDeviceObserver.callObservers removeObject:proxy];
            }
        }
    };
}


#pragma mark - 是否使用耳机
static NSNumber *_usingAudioPort;
+ (BOOL)usingAudioPort {
    if (!_usingAudioPort) {
        AVAudioSessionRouteDescription *currentRoute = AVAudioSession.sharedInstance.currentRoute;
        for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
            if ([output.portType isEqualToString:AVAudioSessionPortHeadphones] ||
                [output.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
                [output.portType isEqualToString:AVAudioSessionPortBluetoothLE] ||
                [output.portType isEqualToString:AVAudioSessionPortAirPlay] ||
                [output.portType isEqualToString:AVAudioSessionPortUSBAudio] ||
                [output.portType isEqualToString:AVAudioSessionPortCarAudio]) {
                _usingAudioPort = @(YES);
              }
        }
    }
    return _usingAudioPort.boolValue;
}

+ (void)setUsingAudioPort:(BOOL)usingAudioPort {
    _usingAudioPort = @(usingAudioPort);
}


#pragma mark - 耳机状态监听
+ (void)aVAudioSessionRouteChangeNotification:(NSNotification *)notification {
    AVAudioSessionRouteChangeReason routeChangeReason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            self.usingAudioPort = YES;
            break;

        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            self.usingAudioPort = NO;
        }
            break;

        default:
            break;
    }
}


#pragma mark - AFDeviceDelegate
- (void)deviceDidChangeMuteStatus:(BOOL)isMute {
    if (self.muteCompletion) self.muteCompletion(isMute);
    self.muteCompletion = nil;
}

- (void)deviceDidChangeCallStatu:(NSString *)callStatus {}


@end
