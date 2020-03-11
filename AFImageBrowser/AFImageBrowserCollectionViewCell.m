//
//  AFImageBrowserCollectionViewCell.m
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "AFImageBrowserCollectionViewCell.h"
#import "AFImageBrowserItem.h"
#import <AVFoundation/AVFoundation.h>

@interface AFImageBrowserScrollView: UIScrollView
@end

@implementation AFImageBrowserScrollView
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint point = [self.panGestureRecognizer translationInView:self];
        if (self.contentOffset.y <= 0 && point.y > 0) {
            return point.y < fabs(point.x);
        } else if (self.contentOffset.y + self.frame.size.height >= self.contentSize.height && point.y < 0) {
            return fabs(point.y) < fabs(point.x);
        }
    }
    return YES;
}
@end


@interface AFImageBrowserCollectionViewCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

/** 图片容器 */
@property (nonatomic, strong) UIView              *imageContainerView;

/** 播放器 */
@property (nonatomic, strong) AVPlayer            *player;

/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer       *playerLayer;

/** item */
@property (strong, nonatomic) AFImageBrowserItem  *item;

/** 记录indexPath */
@property (strong, nonatomic) NSIndexPath         *indexPath;

@end

@implementation AFImageBrowserCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _scrollView = [[AFImageBrowserScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 3;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
//        _imageContainerView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:_imageContainerView];
        
        _imageView = [[UIImageView alloc] init];
        //        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.5];
//        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        [_imageContainerView addSubview:_imageView];

        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoStatus:) name:@"AFImageBrowserUpdateVideoStatus" object:nil];
    }
    return self;
}


- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [UIView new];
        _playerView.frame = self.bounds;
        _playerView.hidden = YES;
        [self addSubview:_playerView];
    }
    return _playerView;
}



#pragma mark - 绑定数据
- (void)attachItem:(AFImageBrowserItem *)item atIndexPath:(NSIndexPath *)indexPath {
    self.item = item;
    self.indexPath = indexPath;
    
    switch (item.type) {
        case AFBrowserItemTypeUIImage: {
            [_scrollView setZoomScale:1.0];
            if ([item.image isKindOfClass:[UIImage class]]) {
                self.imageView.image = item.image;
            } else {
                self.imageView.image = [UIImage new];
            }
            [self resizeSubviewSize];
        }
            break;
            
        case AFBrowserItemTypeImageName: {
            [_scrollView setZoomScale:1.0];
            if ([item.image isKindOfClass:[NSString class]]) {
                self.imageView.image = [UIImage imageNamed:item.image];
            } else {
                self.imageView.image = [UIImage new];
            }
            [self resizeSubviewSize];
            //设置缩放比例为适应屏幕高度
            //    self.scrollView.maximumZoomScale = HScreen_Height/(HScreen_Width * image.size.height/image.size.width);
        }
            break;
            
        case AFBrowserItemTypeImageUrl: {
            [_scrollView setZoomScale:1.0];
            NSURL *url;
            if ([item.image isKindOfClass:[NSURL class]]) {
                url = item.image;
            } else if ([item.image isKindOfClass:[NSString class]]) {
                url = [NSURL URLWithString:item.image];
            } else {
                url = [NSURL URLWithString:@""];
            }
        #warning 占位图
            [self.imageView sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [self resizeSubviewSize];
            }];
        }
            break;
            
        case AFBrowserItemTypeVideoUrl: {
            NSURL *url;
            if ([item.video isKindOfClass:[NSURL class]]) {
               url = item.video;
            } else if ([item.video isKindOfClass:[NSString class]]) {
               url = [NSURL URLWithString:item.video];
            } else {
               url = [NSURL URLWithString:@""];
            }
            
        //    self.currentItem = [AVPlayerItem playerItemWithURL:URL];
            self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
            self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            self.playerLayer.frame = self.bounds;
            [self.playerView.layer addSublayer:self.playerLayer];
            if (@available(iOS 10.0, *)) {
                self.player.automaticallyWaitsToMinimizeStalling = NO;
            }
            [self resizeSubviewSize];
        }
            break;
    }
}



#pragma mark - 更新布局
- (void)resizeSubviewSize {
    
    //视频
    if (self.item.type == AFBrowserItemTypeVideoUrl) {
        _scrollView.hidden = YES;
        _playerView.hidden = NO;
    }
    
    //图片
    else {
        [_player pause];
        _playerView.hidden = YES;
        _scrollView.hidden = NO;
        _imageContainerView.origin = CGPointZero;
        _imageContainerView.width = _scrollView.width;
        
        UIImage *image = _imageView.image;
        //如果图片自适应屏幕宽度后得到的高度 大于 屏幕高度，设置高度为自适应高度
        if (image.size.height / image.size.width > _scrollView.height / _scrollView.width) {
            _imageContainerView.height = floor(image.size.height / (image.size.width / _scrollView.width));
        } else {
            //设置高度为屏幕高度
            CGFloat height = image.size.height / image.size.width * _scrollView.width;
            if (height < 1 || isnan(height)) height = _scrollView.height;
            height = floor(height);
            _imageContainerView.height = height;
            _imageContainerView.centerY = _scrollView.height / 2;
        }
        if (_imageContainerView.height > _scrollView.height && _imageContainerView.height - _scrollView.height <= 1) {
            _imageContainerView.height = _scrollView.height;
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.width, MAX(_imageContainerView.height, _scrollView.height));
        [_scrollView scrollRectToVisible:_scrollView.bounds animated:NO];
        
        //如果高度小于屏幕高度，关闭反弹
        if (_imageContainerView.height <= _scrollView.height) {
            _scrollView.alwaysBounceVertical = NO;
        } else {
            _scrollView.alwaysBounceVertical = YES;
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _imageView.frame = _imageContainerView.bounds;
        [CATransaction commit];
    }
}



#pragma mark - 单击手势
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(singleTap)]) {
        [self.delegate singleTap];
    }
}



#pragma mark - 双击手势
- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {

        CGPoint touchPoint = [tap locationInView:_imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = [[UIScreen mainScreen] bounds].size.width / newZoomScale;
        CGFloat ysize = [[UIScreen mainScreen] bounds].size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}


#pragma mark - UIScrollViewDelegate
//返回一个允许缩放的视图
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

//缩放时调用，更新布局，视图顶格贴边展示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    UIView *subView = _imageContainerView;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}



#pragma mark - 滑动时 更新视频状态
- (void)updateVideoStatus:(NSNotification *)notification {
    
    if (self.item.type != AFBrowserItemTypeVideoUrl) return;
    MOLog(@"-------------------------- 播放 --------------------------");
    // 播放视频
    if ([@(self.indexPath.item) isEqualToNumber:notification.object]) {
        [self.player play];
    }
    
    // 暂停视频
    else {
        [self.player pause];
        [self.player seekToTime:(kCMTimeZero)];
    }
}

@end


