//
//  AFAVCaptureViewController.m
//  AFModule
//
//  Created by alfie on 2020/3/12.
//

#import "AFAVCaptureViewController.h"
#import "AFAVEditViewController.h"
#import "AFAVCapture.h"
#import "AFAVFocusView.h"
#import "UIView+AFExtension.h"
#import "AFTimer.h"

@interface AFAVCaptureViewController () <AFAVCaptureDelegate, AFAVEditViewControllerDelegate> {
}

/** 采集工具 */
@property (nonatomic, strong) AFAVCapture    *avCapture;

/** 捕获预览视图 */
@property (nonatomic, strong) UIImageView    *captureView;

/** 摄像头切换按钮 */
@property (nonatomic, strong) UIButton       *switchCameraBtn;

/** 退出按钮 */
@property (nonatomic, strong) UIButton       *dismissBtn;

/** 拍摄按钮 */
@property (nonatomic, strong) UIView         *captureBtn;

/** 白色圆心 */
@property (nonatomic, strong) UIView         *whiteView;

/** 环形进度条 */
@property (nonatomic, strong) CAShapeLayer   *progressLayer;

/** 当前焦距比例系数 */
@property (nonatomic, assign) CGFloat        currentZoomFactor;
 
/** 当前聚焦视图 */
@property (nonatomic, strong) AFAVFocusView  *focusView;

/** 定时器 */
@property (nonatomic, strong) AFTimer        *timer;

/** 记录时间 */
@property (nonatomic, assign) NSTimeInterval durationTime;

@end


@implementation AFAVCaptureViewController

#pragma mark - 生命周期
- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.pushEditWhenCaptureFinished = YES;
        self.maxDuration = 15;
        self.captureOption = AFCaptureTypeAV;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.avCapture startRunning];
    [self focusAtPoint:CGPointMake(UIScreen.mainScreen.bounds.size.width / 2.0, UIScreen.mainScreen.bounds.size.height / 2.0)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    [_avCapture stopRunning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}


#pragma mark - 配置UI
- (void)configSubViews {

    self.view.backgroundColor = [UIColor whiteColor];
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:self.class] URLForResource:@"AFModule" withExtension:@"bundle"]];
    self.timer = [AFTimer timerWithTimeInterval:0.1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES forMode:(NSRunLoopCommonModes)];

    // 展示容器
    _captureView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _captureView.contentMode = UIViewContentModeScaleAspectFit;
    _captureView.backgroundColor = [UIColor blackColor];
    _captureView.userInteractionEnabled = YES;
    UITapGestureRecognizer *captureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFocusing:)];
    [_captureView addGestureRecognizer:captureTap];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFocalLength:)];
    [_captureView addGestureRecognizer:pinch];
    [self.view addSubview:_captureView];

    // 采集工具
    _avCapture = [[AFAVCapture alloc] init];
    _avCapture.preview = self.captureView;
    _avCapture.delegate = self;
    
    // 退出按钮
    _dismissBtn = [[UIButton alloc] init];
    _dismissBtn.frame = CGRectMake(30, self.view.height - ([UIApplication sharedApplication].statusBarFrame.size.height == 20 ? 80 : 100), 50, 50);
    [_dismissBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_avCapture_dismiss@3x" ofType:@".png"]] forState:(UIControlStateNormal)];
    [_dismissBtn addTarget:self action:@selector(dismissBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_dismissBtn];

    // 切换摄像头按钮
    _switchCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 80, _dismissBtn.y , _dismissBtn.width, _dismissBtn.height)];
    [_switchCameraBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_avCapture_switchCamera@3x" ofType:@".png"]] forState:(UIControlStateNormal)];
    [_switchCameraBtn addTarget:self action:@selector(switchCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_switchCameraBtn];
    
    // 拍摄按钮
    _captureBtn = [[UIView alloc] init];
    _captureBtn.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captureImageAction:)];
    [_captureBtn addGestureRecognizer:tap];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(captureAVAction:)];
    longPress.minimumPressDuration = 0.3;
    [_captureBtn addGestureRecognizer:longPress];
    
    _whiteView = [UIView new];
    _whiteView.backgroundColor = [UIColor whiteColor];
    [_captureBtn addSubview:_whiteView];
    [self.view addSubview:_captureBtn];
    [self layoutCaptureBtn:NO];
    
    // 提示文本
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.width - 140)/2.0, self.captureBtn.y - 20 - 30, 140, 20)];
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.font = [UIFont systemFontOfSize:14];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    if (self.captureOption == AFAVCaptureOptionImage) {
        tipsLabel.text = @"轻触拍照";
    } else if (self.captureOption == AFAVCaptureOptionAV) {
        tipsLabel.text = @"长按摄像";
    } else {
        tipsLabel.text = @"轻触拍照，长按摄像";
    }
    [self.view addSubview:tipsLabel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tipsLabel removeFromSuperview];
    });
}


- (void)layoutCaptureBtn:(BOOL)isRunning {
    if (isRunning) {
        _whiteView.frame  = CGRectMake(35, 35, 30, 30);
        _captureBtn.frame = CGRectMake(self.view.width/2.0 - 50, _dismissBtn.y - 25, 100, 100);
    } else {
        _whiteView.frame  = CGRectMake(10, 10, 50, 50);
        _captureBtn.frame = CGRectMake(self.view.width/2.0 - 35, _dismissBtn.y - 10, 70, 70);
    }
    _whiteView.layer.cornerRadius  = _whiteView.width/2.0;
    _captureBtn.layer.cornerRadius = _captureBtn.width/2.0;
}


- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.captureBtn.frame.size.width/2.0, self.captureBtn.frame.size.height/2.0) radius:self.captureBtn.frame.size.width/2.0 startAngle:- M_PI_2 endAngle:-M_PI_2 + M_PI * 2 clockwise:YES];
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = _captureBtn.bounds;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.lineWidth = 10;
        _progressLayer.lineCap = kCALineCapButt;
        _progressLayer.strokeColor = [UIColor colorWithRed:45/255.0 green:175/255.0 blue:45/255.0 alpha:1].CGColor;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        _progressLayer.path = path.CGPath;
    }
    return _progressLayer;
}


- (AFAVFocusView *)focusView {
    if (_focusView == nil) {
        _focusView= [[AFAVFocusView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    }
    return _focusView;
}


#pragma mark - 退出
- (void)dismissBtnAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 聚焦手势
- (void)tapFocusing:(UITapGestureRecognizer *)tap {
    if(!self.avCapture.isRunning) return;
    CGPoint point = [tap locationInView:self.captureView];
    if(point.y > self.captureBtn.y) return;
    [self focusAtPoint:point];
}

//设置焦点视图位置
- (void)focusAtPoint:(CGPoint)point {
    self.focusView.center = point;
    [self.focusView removeFromSuperview];
    [self.view addSubview:self.focusView];
    self.focusView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    [UIView animateWithDuration:0.5 animations:^{
        self.focusView.transform = CGAffineTransformIdentity;
    }];
    [self.avCapture focusAtPoint:point];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.focusView removeFromSuperview];
    });
}

//调节焦距 手势
- (void)pinchFocalLength:(UIPinchGestureRecognizer *)pinch {
    if(pinch.state == UIGestureRecognizerStateBegan) {
        self.currentZoomFactor = self.avCapture.videoZoomFactor;
    }
    if (pinch.state == UIGestureRecognizerStateChanged) {
        self.avCapture.videoZoomFactor = self.currentZoomFactor * pinch.scale;
    }
}


#pragma mark - 切换前/后摄像头
- (void)switchCameraAction {
    if (self.avCapture.devicePosition == AVCaptureDevicePositionFront) {
        [self.avCapture switchsCamera:AVCaptureDevicePositionBack];
    } else if(self.avCapture.devicePosition == AVCaptureDevicePositionBack) {
        [self.avCapture switchsCamera:AVCaptureDevicePositionFront];
    }
}


#pragma mark - 轻触拍照
- (void)captureImageAction:(UITapGestureRecognizer *)tap {
    if (self.captureOption == AFCaptureTypeAV) return;
    [self.avCapture startCaptureWithOutputFilePath:nil captureType:(AFCaptureTypeImage)];
}


#pragma mark - 长按手势，触发录制
- (void)captureAVAction:(UILongPressGestureRecognizer *)longPress {
    if (self.captureOption == AFCaptureTypeImage) return;
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:{
            [self startCaptureAV];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self stopCaptureAV];
        }
            break;
        default:
            break;
    }
}


#pragma mark -开始录制视频
- (void)startCaptureAV{
    [self layoutCaptureBtn:YES];
    [self.captureBtn.layer addSublayer:self.progressLayer];
    self.progressLayer.strokeEnd = 0;
    NSString *outputVideoFielPath = [NSTemporaryDirectory() stringByAppendingString:@"myVideo.mp4"];
    [self.avCapture startCaptureWithOutputFilePath:outputVideoFielPath captureType:(AFCaptureTypeAV)];
    self.durationTime = 0.f;
    [self.timer fire]; // 开启定时器
}


- (void)timerAction {
    self.durationTime += 0.1;
    if (self.durationTime >= 15) {
        [self stopCaptureAV];
    } else {
        self.progressLayer.strokeEnd = self.durationTime/self.maxDuration;
    }
}


#pragma mark - 结束录制视频
- (void)stopCaptureAV {
    [self layoutCaptureBtn:NO];
    [self.timer invalidate];
    self.durationTime = 0;
    self.progressLayer.strokeEnd = 0;
    [self.progressLayer removeFromSuperlayer];
    [self.avCapture stopCapture];
    [self.avCapture stopRunning];
}


#pragma mark -设备方向改变 AFAVCaptureDelegate
- (void)capture:(AFAVCapture *)capture deviceOrientationChanged:(UIDeviceOrientation)deviceOrientation {
    [UIView animateWithDuration:0.3 animations:^{
        switch (deviceOrientation) {
            case UIDeviceOrientationPortrait:
                self.switchCameraBtn.transform = CGAffineTransformMakeRotation(0);
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.switchCameraBtn.transform = CGAffineTransformMakeRotation(M_PI/2.0);
                break;
            case UIDeviceOrientationLandscapeRight:
                self.switchCameraBtn.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.switchCameraBtn.transform = CGAffineTransformMakeRotation(-M_PI);
                break;
            default:
                break;
        }
    }];
}


#pragma mark - 采集结束 输出图片 AFAVCaptureDelegate
- (void)capture:(AFAVCapture *)capture didFinishCaptureImage:(UIImage *)image {
    [self.avCapture stopRunning];
    if (self.pushEditWhenCaptureFinished) {
        AFAVEditViewController *editVc = [AFAVEditViewController editWithImage:image];
        editVc.delegate = self;
        editVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:editVc animated:NO completion:nil];
    } else {
        if ([self.delegate respondsToSelector:@selector(captureViewController:outputImage:)]) {
            [self.delegate captureViewController:self outputImage:image];
        }
        [self saveImageToAlbum:image];
    }
}


#pragma mark - 采集结束 AFAVCaptureDelegate
- (void)capture:(AFAVCapture *)capture didFinishCaptureAVWithOutputFile:(NSURL *)outputFileURL {

    NSLog(@"结束录制，视频文件大小 === %fM", [[NSFileManager defaultManager] attributesOfItemAtPath:outputFileURL.path error:nil].fileSize/(1024.0*1024.0));
    [self.avCapture stopRunning];
    if (self.pushEditWhenCaptureFinished) {
        AFAVEditViewController *editVc = [AFAVEditViewController editWithAVUrl:outputFileURL];
        editVc.delegate = self;
        editVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:editVc animated:NO completion:nil];
    } else {
        [self outputVideo:outputFileURL];
    }
}


#pragma mark - 采集音视频错误 AFAVCaptureDelegate
- (void)capture:(AFAVCapture *)capture didFinishCaptureError:(NSError *)error type:(AFCaptureType)type {
    NSLog(@"type:%lu, 采集音视频错误:%@", (unsigned long)type, error);
    if ([self.delegate respondsToSelector:@selector(captureViewController:outputError:option:)]) {
        [self.delegate captureViewController:self outputError:error option:self.captureOption];
    }
}


#pragma mark - 完成图片编辑 AFAVEditViewControllerDelegate
- (void)confirmEditImage:(UIImage *)image {
    if ([self.delegate respondsToSelector:@selector(captureViewController:outputImage:)]) {
        [self.delegate captureViewController:self outputImage:image];
    }
    [self saveImageToAlbum:image];
    [self dismissBtnAction];
    [self dismissBtnAction];
}


#pragma mark - 完成视频编辑 AFAVEditViewControllerDelegate
- (void)confirmEditVideo:(NSURL *)url {
    [self outputVideo:url];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissBtnAction];
}


#pragma mark - 输出音视频
- (void)outputVideo:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(captureViewController:outputAV:coverImage:)]) {
        // 获取视频首帧图片
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetImageGenerator *assetGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetGenerator.appliesPreferredTrackTransform = YES;
        NSError *error;
        CMTime actualTime;
        CGImageRef cgImage = [assetGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(0.0, 600) actualTime:&actualTime error:&error];
        UIImage *image = [[UIImage alloc] initWithCGImage:cgImage];
        CGImageRelease(cgImage);
        [self.delegate captureViewController:self outputAV:asset coverImage:image];
    }
    [self saveAvToAlbum:url];
}


#pragma mark - 重新拍摄
- (void)reCaptureAction {
    [self.avCapture startRunning];
}


#pragma mark - 保存图片到本地相册
- (void)saveImageToAlbum:(UIImage *)image {
    if (self.saveToAlbumEnable) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }
}

//保存图片完成后调用的方法
- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissBtnAction];
    });
    if (error) NSLog(@"保存到相册失败:%@", error);
}


#pragma mark - 保存视频到本地相册
- (void)saveAvToAlbum:(NSURL *)url {
    if (self.saveToAlbumEnable) {
        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [photoLibrary performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissBtnAction];
            });
            if (error) NSLog(@"保存到相册失败:%@", error);
        }];
    }
}

@end
