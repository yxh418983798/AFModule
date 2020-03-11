//
//  AFPlayer.m
//  AFModule
//
//  Created by alfie on 2020/3/9.
//

#import "AFPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"
#import "AFBrowserItem.h"

@interface AFPlayer ()

/** 播放器 */
@property (nonatomic, strong) AVPlayer                *player;

/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer           *playerLayer;

/** 封面图 */
@property (strong, nonatomic) UIImageView             *coverImgView;

/** 中间的播放按钮 */
@property (strong, nonatomic) UIButton                *playBtn;

/** 加载进度提示 */
@property (strong, nonatomic) UIActivityIndicatorView *activityView;

/** url */
@property (strong, nonatomic) NSURL         *url;

/** 准备完成后是否自动播放，默认No */
@property (assign, nonatomic) BOOL          playWhenPrepareDone;

/** 记录是否在播放中 */
@property (assign, nonatomic) BOOL          isPlaying;

/** 监听进度对象 */
@property (strong, nonatomic) id            playerObserver;

/** 记录进度 */
@property (assign, nonatomic) CGFloat       progress;

/** 记录时长 */
@property (assign, nonatomic) float         duration;

@end


@implementation AFPlayer

#pragma mark - 生命周期
- (void)didMoveToSuperview {
    self.clipsToBounds = YES;
    self.frame = self.superview.bounds;
    [self.layer addSublayer:self.playerLayer];
    [self addSubview:self.coverImgView];
    [self.coverImgView addSubview:self.activityView];
    [self addSubview:self.playBtn];
    [self addSubview:self.bottomBar];
}


- (void)layoutSubviews {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    [CATransaction setDisableActions:YES];
    self.playerLayer.frame = self.bounds;
    [CATransaction commit];
    CGFloat size = 50.f;
    self.coverImgView.frame = self.bounds;
    self.playBtn.frame = CGRectMake((self.frame.size.width - size)/2, (self.frame.size.height - size)/2, size, size);
    self.activityView.frame = CGRectMake((self.frame.size.width - size)/2, (self.frame.size.height - size)/2, size, size);
    self.bottomBar.frame = CGRectMake(0, self.frame.size.height - 80, self.frame.size.width, 50);
    [super layoutSubviews];
}


- (void)dealloc {
    if (self.playerObserver) {
        [self.player removeTimeObserver:self.playerObserver];
        self.playerObserver = nil;
    }
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        [_playerLayer removeFromSuperlayer];
        _player = nil;
        _playerLayer = nil;
    }
}


// 控制器即将销毁，做一些转场动画的处理
- (void)browserWillDismiss {
    self.bottomBar.alpha = 0;
    self.playBtn.hidden = YES;
    [self.activityView stopAnimating];
}


/**
 * 控制器取消Dismiss，做一些恢复处理
 */
- (void)browserCancelDismiss {
    self.showToolBar = self.showToolBar;
    self.playBtn.hidden = self.isPlaying;
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        self.coverImgView.hidden = YES;
        [self.activityView stopAnimating];
    } else {
        self.coverImgView.hidden = NO;
        [self.activityView startAnimating];
    }
}


- (void)setShowToolBar:(BOOL)showToolBar {
    _showToolBar = showToolBar;
    self.bottomBar.alpha = _showToolBar ? 1 : 0;
    
}


#pragma mark - UI
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [UIImageView new];
    }
    return _coverImgView;
}


- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton new];
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:self.class] URLForResource:@"AFModule" withExtension:@"bundle"]];
        [_playBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_player_play@2x" ofType:@".png"]] forState:(UIControlStateNormal)];
        [_playBtn addTarget:self action:@selector(play) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _playBtn;
}


- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.hidesWhenStopped = YES;
        _activityView.transform = CGAffineTransformMakeScale(2.f, 2.f);
    }
    return _activityView;
}


- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:nil];
        _player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        if (@available(iOS 10.0, *)) {
            _player.automaticallyWaitsToMinimizeStalling = NO;
        }
    }
    return _player;
}


- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.videoGravity = AVLayerVideoGravityResize;
        _playerLayer.masksToBounds= YES;
    }
    return _playerLayer;
}


- (AFPlayerBottomBar *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [AFPlayerBottomBar new];
        [_bottomBar.playBtn addTarget:self action:@selector(playBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//        _bottomBar.slider.delegate = self;
        [_bottomBar.slider addTarget:self action:@selector(sliderTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_bottomBar.slider addTarget:self action:@selector(sliderTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBar.slider addTarget:self action:@selector(sliderTouchUpAction:) forControlEvents:UIControlEventTouchCancel];
        [_bottomBar.slider addTarget:self action:@selector(sliderTouchUpAction:) forControlEvents:UIControlEventTouchUpOutside];
        [_bottomBar.slider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _bottomBar;
}


#pragma mark - 准备播放
- (void)prepareWithURL:(NSURL *)url duration:(float)duration {

    if (self.player.currentItem) {
        if ([self.url isEqual:url]) return;
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    self.url = url;
    self.progress = 0.f;
    self.duration = duration;
    self.playWhenPrepareDone = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    });
    [self.bottomBar updateProgressWithCurrentTime:0.f durationTime:duration];

    if (self.playerObserver) {
        [self.player removeTimeObserver:self.playerObserver];
        self.playerObserver = nil;
    } else {
        __weak typeof(self) weakSelf = self;
        self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            weakSelf.progress = CMTimeGetSeconds(time) / CMTimeGetSeconds(weakSelf.player.currentItem.duration);
            [weakSelf.bottomBar updateProgressWithCurrentTime:CMTimeGetSeconds(time) durationTime:CMTimeGetSeconds(weakSelf.player.currentItem.duration)];
            if (weakSelf.progress >= 1.0) {
                if ([weakSelf.delegate respondsToSelector:@selector(finishWithPlayer:)]) {
                    [weakSelf.delegate finishWithPlayer:weakSelf];
                }
                [weakSelf pause];
            }
        }];
    }
    
    self.coverImgView.hidden = NO;
    self.playBtn.hidden = YES;
    if ([self.coverImage isKindOfClass:NSString.class]) {
        [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:(NSString *)self.coverImage]];
    } else if ([self.coverImgView isKindOfClass:NSURL.class]) {
            [self.coverImgView sd_setImageWithURL:(NSURL *)self.coverImage];
    } else if ([self.coverImgView isKindOfClass:UIImage.class]) {
        self.coverImgView.image = self.coverImage;
    } else {
        self.coverImgView.image = [UIImage new];
    }
    [self.activityView startAnimating];
}


#pragma mark - 播放
- (void)play {
    self.isPlaying = YES;
    self.playWhenPrepareDone = YES;
    self.bottomBar.playBtn.selected = YES;
    self.playBtn.hidden = YES;
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        self.coverImgView.hidden = YES;
        if (self.progress >= 1) {
            [self seekToTime:0.f];
        }
        [self.player play];
    }
}


- (void)playBtnAction:(UIButton *)playBtn {
    playBtn.selected ? [self pause] : [self play];
}


#pragma mark - 暂停
- (void)pause {
    self.bottomBar.playBtn.selected = NO;
    self.playWhenPrepareDone = NO;
    self.isPlaying = NO;
    self.playBtn.hidden = NO;
    [self.player pause];
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        self.playBtn.hidden = NO;
        self.coverImgView.hidden = YES;
    } else {
        self.coverImgView.hidden = NO;
        [self.activityView startAnimating];
    }
}


#pragma mark - 停止
- (void)stop {
    self.isPlaying = NO;
    if (self.player.currentItem) {
        [self.player pause];
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    if (self.playerObserver) {
        [self.player removeTimeObserver:self.playerObserver];
        self.playerObserver = nil;
    }
    [self.player replaceCurrentItemWithPlayerItem:nil];
}


#pragma mark - 跳转
- (void)seekToTime:(NSTimeInterval)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentItem.asset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.currentItem.status) {
                
            case AVPlayerItemStatusReadyToPlay:
                [self.bottomBar updateProgressWithCurrentTime:0.f durationTime:CMTimeGetSeconds(self.player.currentItem.duration)];
                if ([self.delegate respondsToSelector:@selector(prepareDoneWithPlayer:)]) {
                    [self.delegate prepareDoneWithPlayer:self];
                }
                if (self.playWhenPrepareDone) {
                    [self play];
                } else {
                    self.playBtn.hidden = NO;
                }
                [self.activityView stopAnimating];
                break;
                
            case AVPlayerItemStatusFailed:
                NSLog(@"-------------------------- 播放错误 --------------------------");
                break;
                
            default:
                break;
        }
    }
}



#pragma mark - SliderAction
- (void)sliderTouchDownAction:(UISlider *)sender{
    self.bottomBar.isSliderTouch = YES;
    NSLog(@"-------------------------- 123 --------------------------");
}

- (void)sliderValueChangedAction:(UISlider *)sender {
    [self.player pause];
    [self seekToTime:(sender.value * CMTimeGetSeconds(self.player.currentItem.duration))];
    [self.bottomBar updateProgressWithCurrentTime:sender.value * CMTimeGetSeconds(self.player.currentItem.duration) durationTime:CMTimeGetSeconds(self.player.currentItem.duration)];
}

- (void)sliderTouchUpAction:(UISlider *)sender{
    self.bottomBar.isSliderTouch = NO;
    if (self.isPlaying) {
        self.playWhenPrepareDone = YES;
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        }
    }
}


- (void)slider:(AFPlayerSlider *)slider beginTouchWithValue:(float)value {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodProgressView:dragProgressSliderValue:event:)]) {
//        [self.delegate aliyunVodProgressView:self dragProgressSliderValue:sliderValue event:UIControlEventTouchDownRepeat]; //实际是点击事件
//    }
}

@end
