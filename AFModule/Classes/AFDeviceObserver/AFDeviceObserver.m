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

typedef void(^ObserverCompletion)(BOOL isMute);

@interface AFDeviceObserver () <AFDeviceDelegate>

/** 开始计时的时间 */
@property (nonatomic, strong) NSDate            *beginDate;

/** 定时器 */
@property (nonatomic, strong) AFTimer           *timer;

/** 当前是否静音 */
@property (nonatomic, assign) NSNumber          *isMute;

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

+ (void)initialize {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(aVAudioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
}

#pragma mark - 单例
+ (instancetype)shareObserver {
    static AFDeviceObserver *observer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        observer = AFDeviceObserver.new;
        observer.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"detection.aiff" withExtension:nil] error:nil];
        [observer.player prepareToPlay];
    });
    return observer;
}


#pragma mark - Getter
+ (NSMutableArray <AFWeakProxy *> *)muteObservers {
    static NSMutableArray <AFWeakProxy *> *_observers;
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
    [self.shareObserver setMuteCompletion:completion];
    [self.muteObservers addObject:[AFWeakProxy proxyWithTarget:self.shareObserver]];
    [AFDeviceObserver startMuteObserve];
}


#pragma mark - 添加静音监听者
+ (void)addMuteObserver:(NSObject <AFDeviceDelegate> *)observer {
    if ([observer af_proxy] && [self.muteObservers containsObject:observer.af_proxy]) return;
    [self.muteObservers addObject:[AFWeakProxy proxyWithTarget:observer]];
    [AFDeviceObserver startMuteObserve];
}


#pragma mark - 移除静音监听者
+ (void)removeMuteObserver:(NSObject <AFDeviceDelegate> *)observer {
    if ([self.muteObservers containsObject:observer.af_proxy]) {
        [self.muteObservers removeObject:observer.af_proxy];
        observer.af_proxy = nil;
    }
}

#pragma mark - 开始监听静音状态
+ (void)startMuteObserve {
    if (!AFDeviceObserver.muteObservers.count) return;
    if (AFDeviceObserver.shareObserver.isMuteObserving) return;
    AFDeviceObserver.shareObserver.isMuteObserving = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];//保证不会打断第三方app的音频播放
    [AFDeviceObserver.shareObserver.player play];
    if (!AFDeviceObserver.shareObserver.timer) {
        AFDeviceObserver.shareObserver.timer = [AFTimer timerWithTimeInterval:0.2 target:AFDeviceObserver.shareObserver selector:@selector(timerAction) userInfo:nil repeats:YES forMode:(NSRunLoopCommonModes)];
    }
    [AFDeviceObserver.shareObserver.timer fire];
}

// 定时器
- (void)timerAction {
    _beginDate = NSDate.date;
//    NSLog(@"-------------------------- 进入定时器：%g --------------------------", _beginDate);
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("detection"), CFSTR("aiff"), NULL);
    SystemSoundID systemSoundID;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &systemSoundID);
    AudioServicesAddSystemSoundCompletion(systemSoundID, NULL, NULL, soundCompletion, NULL);
    AudioServicesPlaySystemSound(systemSoundID);
}

// 监听回调
static void soundCompletion(SystemSoundID systemSoundID, void *inClientData) {
    
    AudioServicesRemoveSystemSoundCompletion(systemSoundID);
    NSTimeInterval timeinterval = [[NSDate date] timeIntervalSinceDate:AFDeviceObserver.shareObserver.beginDate];
    BOOL isMute = timeinterval < 0.1;
    if (!AFDeviceObserver.shareObserver.isMute || AFDeviceObserver.shareObserver.isMute.boolValue != isMute) {
        AFDeviceObserver.shareObserver.isMute = @(isMute);
        for (int i = (int)AFDeviceObserver.muteObservers.count - 1; i >= 0; i--) {
            AFWeakProxy *proxy = AFDeviceObserver.muteObservers[i];
            id target = proxy.af_target;
            if (target) {
                if ([target respondsToSelector:@selector(deviceDidChangeMuteStatus:)]) {
                    [target deviceDidChangeMuteStatus:isMute];
                }
                if (target == AFDeviceObserver.shareObserver) {
                    [AFDeviceObserver removeMuteObserver:target];
                    AFDeviceObserver.shareObserver.isMute = nil;
                }
            } else {
                [AFDeviceObserver.muteObservers removeObject:proxy];
            }
        }
    } else {
        for (int i = (int)AFDeviceObserver.muteObservers.count - 1; i >= 0; i--) {
            AFWeakProxy *proxy = AFDeviceObserver.muteObservers[i];
            id target = proxy.af_target;
            if (!target) {
                [AFDeviceObserver.muteObservers removeObject:proxy];
            } else if (target == AFDeviceObserver.shareObserver) {
                [target deviceDidChangeMuteStatus:isMute];
                [AFDeviceObserver removeMuteObserver:target];
                AFDeviceObserver.shareObserver.isMute = nil;
            }
        }
    }
    if (!AFDeviceObserver.muteObservers.count) {
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
    AFDeviceObserver.shareObserver.isMute = nil;
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
        observer.af_proxy = nil;
    }
    if (!AFDeviceObserver.callObservers.count) {
        AFDeviceObserver.shareObserver->_callCenter = nil;
    }
}


#pragma mark - 开始监听设备来电
+ (void)startCallObserve {
    AFDeviceObserver.shareObserver.callCenter.callEventHandler = ^(CTCall *call) {
        if (call.callState == CTCallStateDisconnected) {
            NSLog(@"电话结束或挂断电话");
        } else if (call.callState == CTCallStateConnected) {
            NSLog(@"电话接通");
        } else if(call.callState == CTCallStateIncoming) {
            NSLog(@"来电话");
        } else if (call.callState ==CTCallStateDialing) {
            NSLog(@"拨号打电话(在应用内调用打电话功能)");
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


#pragma mark - AFDeviceDelegate
- (void)deviceDidChangeMuteStatus:(BOOL)isMute {
    if (self.muteCompletion) self.muteCompletion(isMute);
    self.muteCompletion = nil;
}

- (void)deviceDidChangeCallStatu:(NSString *)callStatus {}


#pragma mark - 是否使用耳机
static NSNumber *_usingHeadphones;
+ (BOOL)usingHeadphones {
    if (!_usingHeadphones) {
        AVAudioSessionRouteDescription *currentRoute = AVAudioSession.sharedInstance.currentRoute;
        for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
            if ([output.portType isEqualToString:AVAudioSessionPortHeadphones] || [output.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] || [output.portType isEqualToString:AVAudioSessionPortBluetoothLE]) {
                _usingHeadphones = @(YES);
              }
        }
    }
    return _usingHeadphones.boolValue;
}

+ (void)setUsingHeadphones:(BOOL)usingHeadphones {
    _usingHeadphones = @(usingHeadphones);
}

#pragma mark - 耳机状态监听
+ (void)aVAudioSessionRouteChangeNotification:(NSNotification *)notification {
    AVAudioSessionRouteChangeReason routeChangeReason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            self.usingHeadphones = @(YES);
            break;

        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            self.usingHeadphones = @(NO);
        }
            break;

        default:
            break;
    }
}


@end
