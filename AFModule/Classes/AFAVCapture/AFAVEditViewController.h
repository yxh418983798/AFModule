//
//  AFAVEditViewController.h
//  AFModule
//
//  Created by alfie on 2020/3/12.
//
//  编辑音视频控制器

#import <UIKit/UIKit.h>


@protocol AFAVEditViewControllerDelegate <NSObject>

// 完成图片编辑
- (void)confirmEditImage:(UIImage *)image;

// 完成视频编辑
- (void)confirmEditVideo:(NSURL *)url;

// 重新拍摄
- (void)reCaptureAction;

@end


@interface AFAVEditViewController : UIViewController

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;

+ (instancetype)editWithImage:(UIImage *)image;

+ (instancetype)editWithAVUrl:(NSURL *)url;

/** 代理 */
@property (nonatomic, weak) id <AFAVEditViewControllerDelegate>            delegate;

@end


