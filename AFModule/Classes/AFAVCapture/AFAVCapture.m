//
//  AFAVCapture.m
//  AFModule
//
//  Created by alfie on 2020/3/12.
//

#import "AFAVCapture.h"
#import <CoreMotion/CoreMotion.h>

@interface AFAVCapture () <AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

/** 摄像头采集内容预览 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

/** 采集会话 */
@property (nonatomic, strong) AVCaptureSession           *session;

/** 音频输入 */
@property (nonatomic, strong) AVCaptureDeviceInput       *audioInput;

/** 视频输入 */
@property (nonatomic, strong) AVCaptureDeviceInput       *videoInput;

/** 图片输出 */
@property (nonatomic, strong) AVCaptureOutput            *photoOutput;

/** 视频输出 */
@property (nonatomic, strong) AVCaptureVideoDataOutput   *videoOutput;

/** 音频输出 */
@property (nonatomic, strong) AVCaptureAudioDataOutput   *audioOutput;

/** 音视频数据写入 */
@property (nonatomic, strong) AVAssetWriter              *assetWriter;

/** 视频数据写入 */
@property (nonatomic, strong) AVAssetWriterInput         *videoWriter;

/** 音频数据写入 */
@property (nonatomic, strong) AVAssetWriterInput         *audioWriter;

/** 运动传感器  监测设备方向 */
@property (nonatomic, strong) CMMotionManager            *motionManager;

/** 拍摄录制时的手机方向 */
@property (nonatomic, assign) UIDeviceOrientation        deviceOrientation;

/** 音视频采集类型 默认同时采集音视频 */
@property (nonatomic, assign) AFCaptureType  captureType;

/** 是否能写入 */
@property (nonatomic, assign) BOOL           canWrite;

/** 是否正在录制 */
@property (nonatomic, assign) BOOL           isRecording;

/** 音视频文件输出路径 */
@property (nonatomic, copy)  NSURL           *outputFileURL;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation AFAVCapture

#pragma mark - 生命周期
- (instancetype)init {
    self = [super init];
    if (self) {
        self.videoSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    return self;
}


- (void)dealloc {
    [self stopRunning];
}


#pragma mark - 音视频配置
// 展示容器
- (void)setPreview:(UIView *)preview {
    if (!preview) {
        [self.previewLayer removeFromSuperlayer];
    } else {
        self.previewLayer.frame = preview.bounds;
        [preview.layer addSublayer:self.previewLayer];
    }
    _preview = preview;
}

// 会话
- (AVCaptureSession *)session{
    if (_session == nil){
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPreset1280x720]; // 高质量采集率
        if([_session canAddInput:self.videoInput]) [_session addInput:self.videoInput];     // 添加视频输入
        if([_session canAddInput:self.audioInput])  [_session addInput:self.audioInput];    // 添加音频输入
        if([_session canAddOutput:self.photoOutput]) [_session addOutput:self.photoOutput]; // 添加图片输出
        if([_session canAddOutput:self.videoOutput]) [_session addOutput:self.videoOutput]; // 视频数据输出流 纯画面
        if([_session canAddOutput:self.audioOutput]) [_session addOutput:self.audioOutput]; // 音频数据输出流
        AVCaptureConnection * captureVideoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        // 前置摄像头采集到的数据是翻转的，设置镜像把画面转回来
        if (self.devicePosition == AVCaptureDevicePositionFront && captureVideoConnection.supportsVideoMirroring) {
            captureVideoConnection.videoMirrored = YES;
        }
        captureVideoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return _session;
}

// 视频输入
- (AVCaptureDeviceInput *)videoInput {
    if (!_videoInput) {
        NSError *error;
        AVCaptureDevice *videoCaptureDevice =  [self captureDeviceWithPosition:AVCaptureDevicePositionBack];
        _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
        if (error) NSLog(@"获得摄像头失败：%@", error);
    }
    return _videoInput;
}

// 音频输入
- (AVCaptureDeviceInput *)audioInput {
    if (!_audioInput) {
        NSError * error;
        AVCaptureDevice * audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
        if (error) NSLog(@"获取音频输入设备失败：%@", error);
    }
    return _audioInput;
}

// 图片输出
- (AVCaptureOutput *)photoOutput {
    if (!_photoOutput) {
        if (@available(iOS 10.0, *)) {
            _photoOutput = [[AVCapturePhotoOutput alloc] init];
        } else {
            _photoOutput = [[AVCaptureStillImageOutput alloc] init];
            NSDictionary *outputSettings = @{AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill, AVVideoCodecKey : AVVideoCodecJPEG};
            [(AVCaptureStillImageOutput *)_photoOutput setOutputSettings:outputSettings];
        }
    }
    return _photoOutput;
}

// 视频输出
- (AVCaptureVideoDataOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    }
    return _videoOutput;
}

// 音频输出
- (AVCaptureAudioDataOutput *)audioOutput {
    if (!_audioOutput) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    }
    return _audioOutput;
}

// 内容预览
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _previewLayer;
}

// 视频数据写入
- (AVAssetWriterInput *)videoWriter {
    if (!_videoWriter) {
        CGFloat bitsPerPixel = 12.0; // 每像素比特
        NSInteger numPixels = self.videoSize.width * [UIScreen mainScreen].scale * self.videoSize.height * [UIScreen mainScreen].scale; // 写入视频大小
        NSInteger bitsPerSecond = numPixels * bitsPerPixel;
        // 码率和帧率设置
        NSDictionary *compressionProperties = @{
                                                 AVVideoAverageBitRateKey : @(bitsPerSecond),
                                                 AVVideoExpectedSourceFrameRateKey : @(15),
                                                 AVVideoMaxKeyFrameIntervalKey : @(15),
                                                 AVVideoProfileLevelKey : AVVideoProfileLevelH264High40
                                              };
        // 视频属性
        NSDictionary *outputSettings = @{
                                          AVVideoCodecKey : AVVideoCodecH264,
                                          AVVideoWidthKey : @(self.videoSize.width * [UIScreen mainScreen].scale),
                                          AVVideoHeightKey : @(self.videoSize.height * [UIScreen mainScreen].scale),
                                          AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                          AVVideoCompressionPropertiesKey : compressionProperties
                                        };
        _videoWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
        _videoWriter.expectsMediaDataInRealTime = YES; // 从captureSession 实时获取数据
    }
    return _videoWriter;
}

// 音频数据写入
- (AVAssetWriterInput *)audioWriter {
    if (_audioWriter == nil) {
        // 音频设置
        NSDictionary *outputSettings = @{
                                          AVEncoderBitRatePerChannelKey : @(28000),
                                          AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                          AVNumberOfChannelsKey : @(1),
                                          AVSampleRateKey : @(22050)
                                        };
        _audioWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:outputSettings];
        _audioWriter.expectsMediaDataInRealTime = YES; // 从captureSession 实时获取数据
    }
    return _audioWriter;
}

// 输出路径
- (void)setOutputFileURL:(NSURL *)outputFileURL {
    _outputFileURL = outputFileURL;
    NSError *error;
    if (self.captureType == AFCaptureTypeAudio) {
        _assetWriter = [AVAssetWriter assetWriterWithURL:outputFileURL fileType:AVFileTypeAC3 error:&error];
    } else if (self.captureType == AFCaptureTypeVideo || self.captureType == AFCaptureTypeAV) {
        _assetWriter = [AVAssetWriter assetWriterWithURL:outputFileURL fileType:AVFileTypeMPEG4 error:&error];
    }
    if (error) {
        NSLog(@"-------------------------- 输出路径设置错误：%@ --------------------------", error);
    }
}

// 传感器
- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

// 获取指定位置的摄像头
- (AVCaptureDevice *)captureDeviceWithPosition:(AVCaptureDevicePosition)positon {
    
    NSArray <AVCaptureDevice *> *devices;
    if (@available(iOS 10.2, *)) {
        AVCaptureDeviceDiscoverySession *dissession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInDualCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera, AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:positon];
        devices = dissession.devices;
    } else {
        devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    }
    for (AVCaptureDevice *device in devices) {
        if (device.position == positon) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevicePosition)devicePosition {
    return self.videoInput.device.position == AVCaptureDevicePositionUnspecified ? AVCaptureDevicePositionBack : self.videoInput.device.position;
}

// 摄像头是否正在运行
- (BOOL)isRunning {
    return self.session.isRunning;
}

//最小缩放值 焦距
- (CGFloat)minZoomFactor {
    CGFloat minZoomFactor = 1.0;
    if (@available(iOS 11.0, *)) {
        minZoomFactor = [self.videoInput device].minAvailableVideoZoomFactor;
    }
    return minZoomFactor;
}

//最大缩放值 焦距
- (CGFloat)maxZoomFactor {
    CGFloat maxZoomFactor = [self.videoInput device].activeFormat.videoMaxZoomFactor;
    if (@available(iOS 11.0, *)) {
        maxZoomFactor = [self.videoInput device].maxAvailableVideoZoomFactor;
    }
    if (maxZoomFactor > 6) {
        maxZoomFactor = 6.0;
    }
    return maxZoomFactor;
}

// 当前焦距
- (CGFloat)videoZoomFactor {
    return self.videoInput.device.videoZoomFactor;
}

// 调节焦距
- (void)setVideoZoomFactor:(CGFloat)videoZoomFactor {
    NSError *error;
    if (videoZoomFactor <= self.maxZoomFactor && videoZoomFactor >= self.minZoomFactor){
        if ([self.videoInput.device lockForConfiguration:&error] ) {
            self.videoInput.device.videoZoomFactor = videoZoomFactor;
            [self.videoInput.device unlockForConfiguration];
        } else {
            NSLog(@"调节焦距失败: %@", error);
        }
    }
}


#pragma mark - 监听设备方向
// 开始监听
- (void)startUpdateDeviceDirection {
    if ([self.motionManager isAccelerometerAvailable] == YES) {
        //回调会一直调用,建议获取到就调用下面的停止方法，需要再重新开始，当然如果需求是实时不间断的话可以等离开页面之后再stop
        [self.motionManager setAccelerometerUpdateInterval:1.0];
        __weak typeof(self) weakSelf = self;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            double x = accelerometerData.acceleration.x;
            double y = accelerometerData.acceleration.y;
            UIDeviceOrientation deviceOrientation;
            if ((fabs(y) + 0.1f) >= fabs(x)) {
                deviceOrientation = y >= 0.1f ? UIDeviceOrientationPortraitUpsideDown : UIDeviceOrientationPortrait;
            } else {
                if (x >= 0.1f) {
                    deviceOrientation = UIDeviceOrientationLandscapeRight;
                } else if (x <= 0.1f) {
                    deviceOrientation = UIDeviceOrientationLandscapeLeft;
                } else  {
                    deviceOrientation = UIDeviceOrientationPortrait;
                }
            }
            if (weakSelf.deviceOrientation != deviceOrientation) {
                weakSelf.deviceOrientation = deviceOrientation;
                if ([weakSelf.delegate respondsToSelector:@selector(capture:deviceOrientationChanged:)]) {
                    [weakSelf.delegate capture:weakSelf deviceOrientationChanged:deviceOrientation];
                }
            }
        }];
    }
}


// 停止监听方向
- (void)stopUpdateDeviceDirection {
    if ([self.motionManager isAccelerometerActive] == YES) {
        [self.motionManager stopAccelerometerUpdates];
        _motionManager = nil;
    }
}


#pragma mark - 设置聚焦点和模式  默认自动
- (void)focusAtPoint:(CGPoint)point {
    //将UI坐标转化为摄像头坐标  (0,0) -> (1,1)
    CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    AVCaptureDevice *captureDevice = [self.videoInput device];
    NSError * error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            if ([captureDevice isFocusPointOfInterestSupported]) {
                [captureDevice setFocusPointOfInterest:cameraPoint];
            }
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //曝光模式
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            if ([captureDevice isExposurePointOfInterestSupported]) {
                [captureDevice setExposurePointOfInterest:cameraPoint];
            }
            [captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [captureDevice unlockForConfiguration];
    } else {
        NSLog(@"设置聚焦点错误：%@", error.localizedDescription);
    }
}


#pragma mark - 切换前/后置摄像头
- (void)switchsCamera:(AVCaptureDevicePosition)devicePosition {
    
    if (self.devicePosition == devicePosition) return;
    NSError *error;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[self captureDeviceWithPosition:devicePosition] error:&error];
    if (error) NSLog(@"-------------------------- 设置输出设备错误：%@ --------------------------", error);
    
    [self.session beginConfiguration];
    [self.session removeInput:self.videoInput];
    if ([self.session canAddInput:videoInput]) {
        [self.session addInput:videoInput];
        self.videoInput = videoInput;
    }
    
    //视频输入对象发生了改变  视频输出的链接也要重新初始化
    AVCaptureConnection *captureConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoStabilizationSupported]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto; //视频稳定模式
    }
    if (self.devicePosition == AVCaptureDevicePositionFront && captureConnection.supportsVideoMirroring) {
        captureConnection.videoMirrored = YES;
    }
    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.session commitConfiguration];
}


#pragma mark - 启动设备
- (void)startRunning {
    if(!self.session.isRunning) {
        [self.session startRunning];
    }
    [self startUpdateDeviceDirection];
}


#pragma mark - 停止设备
- (void)stopRunning {
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
    [self stopUpdateDeviceDirection];
}


#pragma mark - 开始采集
- (void)startCaptureWithOutputFilePath:(NSString *)path captureType:(AFCaptureType)captureType {
    
    self.captureType = captureType;
    // 采集图片
    if (self.captureType == AFCaptureTypeImage) {
        // 获取图片输出连接
        AVCaptureConnection * captureConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
        // 设置镜像，把画面转回来
        if (self.devicePosition == AVCaptureDevicePositionFront && captureConnection.supportsVideoMirroring) {
            captureConnection.videoMirrored = YES;
        }
        switch (self.deviceOrientation) {
                
            case UIDeviceOrientationLandscapeRight:
                captureConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                captureConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
              
            case UIDeviceOrientationPortraitUpsideDown:
                captureConnection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
                
            default:
                captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
        if (@available(iOS 10.0, *)) {
            // 输出样式设置 AVVideoCodecKey:AVVideoCodecJPEG等
            AVCapturePhotoSettings *capturePhotoSettings = [AVCapturePhotoSettings photoSettings];
            //   capturePhotoSettings.highResolutionPhotoEnabled = YES; //高分辨率
            capturePhotoSettings.flashMode = _flashMode;  //闪光灯 根据环境亮度自动决定是否打开闪光灯
            [(AVCapturePhotoOutput *)self.photoOutput capturePhotoWithSettings:capturePhotoSettings delegate:self];
        } else {
            [(AVCaptureStillImageOutput *)self.photoOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                
                if (error) {
                    if ([self.delegate respondsToSelector:@selector(capture:didFinishCaptureError:type:)]) {
                        [self.delegate capture:self didFinishCaptureError:error type:AFCaptureTypeImage];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(capture:didFinishCaptureImage:)]) {
                        [self.delegate capture:self didFinishCaptureImage:[UIImage imageWithData:[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer]]];
                    }
                }
            }];
        }
        return;
    }
    
    // 移除重复文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    self.outputFileURL = [NSURL fileURLWithPath:path];
    [self stopUpdateDeviceDirection];
    
    // 采集音频
    if (self.captureType == AFCaptureTypeAudio) {
        [self.session beginConfiguration];
        //移除视频输出对象
        [self.session removeOutput:self.videoOutput];
        [self.session commitConfiguration];
        [self addWriteInput:self.audioWriter];
        _isRecording = YES;
    }
    
    // 采集视频/音视频
    else {
        //获得视频输出连接
        AVCaptureConnection * captureConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        // 设置镜像，把画面转回来
        if (self.devicePosition == AVCaptureDevicePositionFront && captureConnection.supportsVideoMirroring) captureConnection.videoMirrored = YES;
        // 直接设置captureConnection.videoOrientation 会在每次开始录制时设置视频输出方向，会造成摄像头的短暂黑暗，故采用在写入输出视频时调整方向
        switch (self.deviceOrientation) {
            case UIDeviceOrientationLandscapeRight:
                self.videoWriter.transform = CGAffineTransformMakeRotation(M_PI / 2);
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                self.videoWriter.transform = CGAffineTransformMakeRotation(-M_PI / 2);
                break;
              
            case UIDeviceOrientationPortraitUpsideDown:
                self.videoWriter.transform = CGAffineTransformMakeRotation(M_PI);
                break;
                
            default:
                self.videoWriter.transform = CGAffineTransformMakeRotation(0);
                break;
        }
        [self addWriteInput:self.videoWriter];
        if (self.captureType == AFCaptureTypeAV) [self addWriteInput:self.audioWriter];
        _isRecording = YES;
    }
}


// 添加数据写入
- (void)addWriteInput:(AVAssetWriterInput *)writeInput {
    if ([self.assetWriter canAddInput:writeInput]) {
        [self.assetWriter addInput:writeInput];
    } else {
        NSLog(@"写入数据失败");
    }
}


#pragma mark - 输出图片 AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error API_AVAILABLE(ios(11.0)) {
    if (error) {
        if ([self.delegate respondsToSelector:@selector(capture:didFinishCaptureError:type:)]) {
            [self.delegate capture:self didFinishCaptureError:error type:AFCaptureTypeImage];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(capture:didFinishCaptureImage:)]) {
            [self.delegate capture:self didFinishCaptureImage:[UIImage imageWithData:[photo fileDataRepresentation]]];
        }
    }
}


#pragma mark - 接收音视频输出的数据 AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    if(!_isRecording || sampleBuffer == NULL) return;
    //写入视频
    if (output == self.videoOutput) {
        if([self.delegate respondsToSelector:@selector(capture:didOutputVideoSampleBuffer:fromConnection:)]) {
            [self.delegate capture:self didOutputVideoSampleBuffer:sampleBuffer fromConnection:connection];
        }
        if (self.captureType == AFCaptureTypeAV || self.captureType == AFCaptureTypeVideo) {
            [self writer:self.videoWriter writeSampleBuffer:sampleBuffer fromConnection:connection];
        }
    }
    
    //写入音频
    else if (output == self.audioOutput) {
        if([self.delegate respondsToSelector:@selector(capture:didOutputAudioSampleBuffer:fromConnection:)]) {
            [self.delegate capture:self didOutputAudioSampleBuffer:sampleBuffer fromConnection:connection];
        }
        if (self.captureType == AFCaptureTypeAudio || self.captureType == AFCaptureTypeAV) {
            [self writer:self.audioWriter writeSampleBuffer:sampleBuffer fromConnection:connection];
        }
    }
}


#pragma mark - 写入音视频数据
- (void)writer:(AVAssetWriterInput *)writer writeSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        @synchronized(self) {
            if (!self.canWrite) {
                [self.assetWriter startWriting];
                [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                self.canWrite = YES;
            }
            if (writer.readyForMoreMediaData) {
                if (![writer appendSampleBuffer:sampleBuffer]) {
                    @synchronized (self) {
                        [self stopCapture];
                    }
                }
            }
        }
    }
}


#pragma mark - 停止写入数据
- (void)finishWriting {
    self.canWrite = NO;
    self.assetWriter = nil;
    self.audioWriter = nil;
    self.videoWriter = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.assetWriter.error) {
            if ([self.delegate respondsToSelector:@selector(capture:didFinishCaptureError:type:)]) {
                [self.delegate capture:self didFinishCaptureError:self.assetWriter.error type:self.captureType];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(capture:didFinishCaptureAVWithOutputFile:)]) {
                [self.delegate capture:self didFinishCaptureAVWithOutputFile:self.outputFileURL];
            }
        }
    });
}


#pragma mark - 结束音视频采集 && 输出音视频路径
- (void)stopCapture {
    
    if (!_isRecording) return;
    _isRecording = NO;
    __weak typeof(self) weakSelf = self;

    if(_assetWriter && self.canWrite) {
        [_assetWriter finishWritingWithCompletionHandler:^{
            [weakSelf finishWriting];
        }];
    }
}


#pragma mark - 丢帧
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(capture:didDropSampleBuffer:fromConnection:)]) {
        [self.delegate capture:self didDropSampleBuffer:sampleBuffer fromConnection:connection];
    }
}

@end
#pragma clang diagnostic pop
