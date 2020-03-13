//
//  AFAVEditViewController.m
//  AFModule
//
//  Created by alfie on 2020/3/12.
//

#import "AFAVEditViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AFPlayer.h"

@interface AFAVEditViewController ()

/** 预览视图 展示编辑的图片或视频 */
@property (nonatomic, strong) UIImageView *imageView;

/** 视频播放器 */
@property (nonatomic, strong) AFPlayer    *player;

/** 返回按钮 */
@property (nonatomic, strong) UIButton    *dismissBtn;

/** 完成按钮 */
@property (nonatomic, strong) UIButton    *confirmBtn;

/** 音视频的路径 */
@property (nonatomic, strong) NSURL       *url;

/** 图片 */
@property (nonatomic, strong) UIImage     *image;

@end


@implementation AFAVEditViewController

#pragma mark - 生命周期
+ (instancetype)editWithImage:(UIImage *)image {
    AFAVEditViewController *editVc = [AFAVEditViewController new];
    editVc.image = image;
    return editVc;
}

+ (instancetype)editWithAVUrl:(NSURL *)url {
    AFAVEditViewController *editVc = [AFAVEditViewController new];
    editVc.url = url;
    return editVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self configSubViews];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark - 配置UI
- (void)configSubViews {
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:self.class] URLForResource:@"AFModule" withExtension:@"bundle"]];

    // 预览图片
    if (self.image) {
        self.imageView.image = self.image;
    } else if (self.url) {
        [self.player prepareWithURL:self.url duration:0];
        [self.player play];
    }

    // 退出按钮
    _dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height - ([UIApplication sharedApplication].statusBarFrame.size.height == 20 ? 100 : 120), 70, 70)];
    _dismissBtn.layer.cornerRadius = _dismissBtn.frame.size.width / 2.0;
    [_dismissBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_avEdit_dismiss@3x" ofType:@".png"]] forState:(UIControlStateNormal)];
    [_dismissBtn addTarget:self action:@selector(dismissBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_dismissBtn];
    
    // 完成按钮
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, _dismissBtn.frame.origin.y, 70, 70)];
    _confirmBtn.backgroundColor = [UIColor colorWithRed:45/255.0 green:175/255.0 blue:45/255.0 alpha:1];
    [_confirmBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_avEdit_confirm@3x" ofType:@".png"]] forState:(UIControlStateNormal)];
    _confirmBtn.layer.cornerRadius = _confirmBtn.frame.size.width / 2.0;
    [_confirmBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmBtn];
}


- (AFPlayer *)player {
    if (!_player) {
        _player = [[AFPlayer alloc] initWithFrame:self.view.bounds];
        _player.showToolBar = NO;
        [self.view addSubview:_player];
    }
    return _player;
}


- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}


#pragma mark - 退出，重新拍摄
- (void)dismissBtnAction {
    if ([self.delegate respondsToSelector:@selector(reCaptureAction)]) {
        [self.delegate reCaptureAction];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - 确认
- (void)confirmBtnAction {
    if (self.image) {
        if ([self.delegate respondsToSelector:@selector(confirmEditImage:)]) {
            [self.delegate confirmEditImage:self.image];
        }
    } else if (self.url) {
        if ([self.delegate respondsToSelector:@selector(confirmEditVideo:)]) {
            [self.delegate confirmEditVideo:self.url];
        }
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}



@end
