//
//  AFAVCapture.h
//  AFModule
//
//  Created by alfie on 2020/3/12.
//
//  音视频采集工具

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/** 采集类型 */
typedef NS_ENUM(NSUInteger, AFCaptureType) {
    AFCaptureTypeAV,    // 默认，同时采集音视频
    AFCaptureTypeVideo, // 视频
    AFCaptureTypeAudio, // 音频
    AFCaptureTypeImage, // 图片
};


@class AFAVCapture;

@protocol AFAVCaptureDelegate <NSObject>
@optional

/**
 * 设备方向改变
 *
 * @param capture           采集工具
 * @param deviceOrientation 设备方向
 */
- (void)capture:(AFAVCapture *)capture deviceOrientationChanged:(UIDeviceOrientation)deviceOrientation;

/**
 * 结束采集 拍照
 *
 * @param capture 采集工具
 * @param image   输出的图片
 */
- (void)capture:(AFAVCapture *)capture didFinishCaptureImage:(UIImage *)image;


/**
 * 结束采集音视频
 *
 * @param outputFileURL 临时文件地址
 */
- (void)capture:(AFAVCapture *)capture didFinishCaptureAVWithOutputFile:(NSURL *)outputFileURL;


/**
 * 采集音视频错误
 *
 * @param error 错误信息
 */
- (void)capture:(AFAVCapture *)capture didFinishCaptureError:(NSError *)error type:(AFCaptureType)type;


/**
 * 实时输出采集的视频样本
 *
 * @param capture      capture
 * @param sampleBuffer 样本缓冲
 * @param connection   输入和输出之前的连接
 */
- (void)capture:(AFAVCapture *)capture didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;


/**
 * 实时输出采集的音频样本
 *
 * @param capture      capture
 * @param sampleBuffer 样本缓冲
 * @param connection   输入和输出之前的连接
 */
- (void)capture:(AFAVCapture *)capture didOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;


/**
 * 丢帧回调， 丢弃的每一帧都会调用一次
 *
 * @param capture      capture
 * @param sampleBuffer 样本缓冲
 * @param connection   输入和输出之前的连接
 */
- (void)capture:(AFAVCapture *)capture didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end


@interface AFAVCapture : NSObject

/** 代理 */
@property (nonatomic, weak) id<AFAVCaptureDelegate> delegate;

/** 父视图，展示容器 */
@property (nonatomic, strong) UIView                *preview;

/** 导出的视频宽高，默认屏幕宽高 */
@property (nonatomic, assign) CGSize                videoSize;

/** 当前焦距 默认最小值1 最大值6 */
@property (nonatomic, assign) CGFloat               videoZoomFactor;

/** 摄像头是否正在运行 */
@property (nonatomic, assign, readonly) BOOL        isRunning;
    
/** 闪光灯状态  默认关闭 */
@property (nonatomic, assign) AVCaptureFlashMode    flashMode;

/** 摄像头方向 默认后置摄像头 */
@property (nonatomic, assign, readonly) AVCaptureDevicePosition devicePosition;


/**
 * 当用户点击屏幕时，调用该方法 设置聚焦点
 */
- (void)focusAtPoint:(CGPoint)point;


/**
 * 切换前/后置摄像头
 */
- (void)switchsCamera:(AVCaptureDevicePosition)devicePosition;


/**
 * 启动设备
 */
- (void)startRunning;


/**
 * 停止设备
 */
- (void)stopRunning;


/**
 * 开始采集
 * 视频默认输出MP4，音频默认输出MP3
 *
 * @param path  结束录制后的输出路径，如果是拍摄图片，path传nil
 * @param captureType 录制类型
 */
- (void)startCaptureWithOutputFilePath:(NSString *)path captureType:(AFCaptureType)captureType;


/**
 * 结束采集，如果是采集图片，不需要调用
 */
- (void)stopCapture;


@end
