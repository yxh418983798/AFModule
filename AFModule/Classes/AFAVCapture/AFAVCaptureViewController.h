//
//  AFAVCaptureViewController.h
//  AFModule
//
//  Created by alfie on 2020/3/12.
//
//  视频采集控制器
//  开发者也可以使用AFAVCapture来采集音视频，自定义UI

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

// 拍摄按钮的行为
typedef NS_ENUM(NSUInteger, AFAVCaptureOption) {
    AFAVCaptureOptionDefault, // 默认，轻触拍照，长按摄像
    AFAVCaptureOptionImage,   // 只能拍照
    AFAVCaptureOptionAV,      // 只能摄像
};


@class AFAVCaptureViewController;
@protocol AFAVCaptureViewControllerDelegate <NSObject>

/**
 * 拍照，输出图片
 *
 * @param captureViewController 控制器
 * @param image                 输出的图片
 */
- (void)captureViewController:(AFAVCaptureViewController *)captureViewController outputImage:(UIImage *)image;


/**
 * 摄像，输出音视频
 *
 * @param captureViewController 控制器
 * @param asset                 AVURLAsset
 * @param coverImage            取视频首帧作为封面图
 */
- (void)captureViewController:(AFAVCaptureViewController *)captureViewController outputAV:(AVURLAsset *)asset coverImage:(UIImage *)coverImage;


/**
 * 输出错误
 *
 * @param captureViewController 控制器
 * @param error                 错误信息
 * @option option               拍摄按钮的行为
 */
- (void)captureViewController:(AFAVCaptureViewController *)captureViewController outputError:(NSError *)error option:(AFAVCaptureOption)option;

@end



@interface AFAVCaptureViewController : UIViewController

/** 代理 */
@property (nonatomic, weak) id <AFAVCaptureViewControllerDelegate>   delegate;

/** 拍摄按钮的行为，默认轻触拍照，长按摄像 */
@property (nonatomic, assign) AFAVCaptureOption captureOption;

/** 拍摄完之后（确认使用） 是否自动将图片/视频 保存到本地相册，默认NO */
@property (nonatomic, assign) BOOL              saveToAlbumEnable;

/** 录制音视频的最大时长，默认15秒 */
@property (nonatomic, assign) NSInteger         maxDuration;

/** 拍摄完之后 是否自动跳转到编辑页面，默认YES */
@property (nonatomic, assign) BOOL              pushEditWhenCaptureFinished;

@end
