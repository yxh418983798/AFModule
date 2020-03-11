//
//  AFPlayerBottomBar.m
//  AFModule
//
//  Created by alfie on 2020/3/9.
//

#import "AFPlayerBottomBar.h"
#import "UIView+AFExtension.h"

@implementation AFPlayerBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
            
        [self addSubview:self.backgroundView];
        [self addSubview:self.playBtn];
        [self addSubview:self.leftTimeLb];
        [self addSubview:self.rightTimeLb];
        [self addSubview:self.loadtimeView];
        [self addSubview:self.slider];
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:nil]];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:nil]];
    }
    return self;
}

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.image = [self imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] size:(CGSizeMake(UIScreen.mainScreen.bounds.size.width - 30, 50))];
        _backgroundView.layer.cornerRadius = 6;
        _backgroundView.clipsToBounds = YES;
    }
    return _backgroundView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:self.class] URLForResource:@"AFModule" withExtension:@"bundle"]];
        [_playBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_player_play@2x" ofType:@".png"]] forState:(UIControlStateNormal)];
        [_playBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_player_pause@2x" ofType:@".png"]] forState:(UIControlStateSelected)];
    }
    return _playBtn;
}

- (UILabel *)leftTimeLb {
    if (!_leftTimeLb) {
        _leftTimeLb = [[UILabel alloc] init];
        _leftTimeLb.textAlignment = NSTextAlignmentLeft;
        [_leftTimeLb setFont:[UIFont systemFontOfSize:12]];
        [_leftTimeLb setTextColor:UIColor.whiteColor];
        _leftTimeLb.text = @"00:00";
    }
    return _leftTimeLb;
}

- (UILabel *)rightTimeLb {
    if (!_rightTimeLb) {
        _rightTimeLb = [[UILabel alloc] init];
        _rightTimeLb.textAlignment = NSTextAlignmentRight;
        [_rightTimeLb setFont:[UIFont systemFontOfSize:12]];
        [_rightTimeLb setTextColor:UIColor.whiteColor];
        _rightTimeLb.text = @"00:00";
    }
    return _rightTimeLb;
}


- (UIProgressView *)loadtimeView {
    if (!_loadtimeView) {
        _loadtimeView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadtimeView.progress = 0.0;
        //设置它的风格，为默认的
        _loadtimeView.trackTintColor= [UIColor clearColor];
        //设置轨道的颜色
        _loadtimeView.progressTintColor= [UIColor whiteColor];
    }
    return _loadtimeView;
}

- (AFPlayerSlider *)slider {
    if (!_slider) {
        _slider = [[AFPlayerSlider alloc] init];
        _slider.value = 0.0;
        _slider.minimumTrackTintColor = [UIColor colorWithRed:(193)/255.0 green:(136)/255.0 blue:(92)/255.0 alpha:(1)];
        _slider.maximumTrackTintColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        [_slider setThumbImage:[self imageWithColor:[UIColor colorWithRed:(193)/255.0 green:(136)/255.0 blue:(92)/255.0 alpha:(1)] size:(CGSizeMake(15, 15))] forState:UIControlStateNormal];
    }
    return _slider;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = CGRectMake(15, 5, self.width - 30, self.height - 10);
    self.playBtn.frame = CGRectMake(15, 0, 50, self.height);
    self.leftTimeLb.frame = CGRectMake(65, 0, 50, self.height);
    self.rightTimeLb.frame = CGRectMake(self.width - 80, 0, 50, self.height);
//    self.loadtimeView.frame = CGRectMake(2, 12, self.bounds.size.width-2*2, 2);
    self.slider.frame = CGRectMake(105, 10, self.width - 175, 30);

}


- (void)setProgress:(float)progress {
    _progress = progress;
    [self.slider setValue:progress animated:YES];
}

- (void)setLoadTimeProgress:(float)loadTimeProgress {
    _loadTimeProgress = loadTimeProgress;
    [self.loadtimeView setProgress:loadTimeProgress];
}


#pragma mark - 更新进度和时间
- (void)updateProgressWithCurrentTime:(float)currentTime durationTime:(float)durationTime {
    self.leftTimeLb.text = [self timeformatFromSeconds:roundf(currentTime)];
    self.rightTimeLb.text = [self timeformatFromSeconds:roundf(durationTime)];
    if (!self.isSliderTouch) {
        [self.slider setValue:durationTime > 0 ? currentTime/durationTime : 0 animated:YES];
    }
}


- (NSString *)timeformatFromSeconds:(NSInteger)seconds {
//    NSString *hour = [NSString stringWithFormat:@"%02ld", (long) seconds / 3600];
//    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long) (seconds % 3600) / 60];
    NSString *minute = [NSString stringWithFormat:@"%02ld", (long) (seconds / 60)];
    NSString *second = [NSString stringWithFormat:@"%02ld", (long) seconds % 60];
    NSString *time = [NSString stringWithFormat:@"%@:%@", minute, second];
//    if (seconds / 3600 <= 0) {
//        time = [NSString stringWithFormat:@"00:%@:%@", str_minute, str_second];
//    } else {
//        time = [NSString stringWithFormat:@"%@:%@:%@", str_hour, str_minute, str_second];
//    }
    return time;
}


#pragma mark - 绘制图片
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    if (size.width == size.height) {
        CGContextAddEllipseInRect(context, rect);
        CGContextClip(context);
    }
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
