//
//  AFBrowserCollectionViewCell.m
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "AFBrowserCollectionViewCell.h"
#import "AFBrowserItem.h"
#import "UIView+AFExtension.h"
#import "UIImageView+WebCache.h"


@interface AFBrowserScrollView: UIScrollView


@end

@implementation AFBrowserScrollView
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


@interface AFBrowserCollectionViewCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

/** 图片容器 */
@property (nonatomic, strong) UIView             *imageContainerView;

/** item */
@property (strong, nonatomic) AFBrowserItem      *item;

/** 记录indexPath */
@property (strong, nonatomic) NSIndexPath        *indexPath;

/** 记录状态 */
@property (assign, nonatomic) AFLoadImageStatus  loadImageStatus;

@end

@implementation AFBrowserCollectionViewCell

#pragma mark - 生命周期
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _scrollView = [[AFBrowserScrollView alloc] init];
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoStatus:) name:@"AFBrowserUpdateVideoStatus" object:nil];
    }
    return self;
}



#pragma mark - UI
- (AFPlayer *)player {
    if (!_player) {
        _player = [[AFPlayer alloc] initWithFrame:(CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height))];
        _player.hidden = self.item.type == AFBrowserItemTypeImage;
        [self addSubview:_player];
    }
    return _player;
}


#pragma mark - 绑定数据
- (void)attachItem:(AFBrowserItem *)item atIndexPath:(NSIndexPath *)indexPath {
    self.item = item;
    self.indexPath = indexPath;
    self.loadImageStatus = AFLoadImageStatusNone;
    
    switch (item.type) {
        case AFBrowserItemTypeImage: {
            [_scrollView setZoomScale:1.0];
            if ([item.item isKindOfClass:NSString.class]) {
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:item.item] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    self.loadImageStatus = AFLoadImageStatusOriginal;
                    [self resizeSubviewSize];
                }];
            } else if ([item.item isKindOfClass:NSURL.class]) {
                [self.imageView sd_setImageWithURL:item.item placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    self.loadImageStatus = AFLoadImageStatusOriginal;
                    [self resizeSubviewSize];
                }];
            } else if ([item.item isKindOfClass:UIImage.class])  {
                self.loadImageStatus = AFLoadImageStatusOriginal;
                self.imageView.image = item.item;
                [self resizeSubviewSize];
                //设置缩放比例为适应屏幕高度
                //    self.scrollView.maximumZoomScale = HScreen_Height/(HScreen_Width * image.size.height/image.size.width);
            } else {
                self.loadImageStatus = AFLoadImageStatusOriginal;
                self.imageView.image = [UIImage new];
                [self resizeSubviewSize];
            }
            if (item.coverImage) {
                if ([item.coverImage isKindOfClass:NSString.class]) {
                    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:item.coverImage] options:kNilOptions progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                        if (self.loadImageStatus == AFLoadImageStatusNone && image) {
                            self.loadImageStatus = AFLoadImageStatusCover;
                            self.imageView.image = image;
                            [self resizeSubviewSize];
                        }
                    }];
                } else if ([item.coverImage isKindOfClass:NSURL.class]) {
                    [[SDWebImageManager sharedManager] loadImageWithURL:item.coverImage options:kNilOptions progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                        if (self.loadImageStatus == AFLoadImageStatusNone && image) {
                            self.loadImageStatus = AFLoadImageStatusCover;
                            self.imageView.image = image;
                            [self resizeSubviewSize];
                        }
                    }];
                } else if ([item.coverImage isKindOfClass:UIImage.class])  {
                    if (self.loadImageStatus == AFLoadImageStatusNone) {
                        self.loadImageStatus = AFLoadImageStatusCover;
                        self.imageView.image = item.coverImage;
                        [self resizeSubviewSize];
                    }
                }
            }
        }
            break;
            
        case AFBrowserItemTypeVideo: {
            self.player.coverImage = item.coverImage;
            NSURL *url;
            if ([item.item isKindOfClass:NSString.class]) {
                url = [NSURL URLWithString:item.item];
            } else if ([item.item isKindOfClass:NSURL.class]) {
                url = item.item;
            } else {
                url = [NSURL URLWithString:@""];
            }
            [self.player prepareWithURL:url duration:item.duration];
            [self resizeSubviewSize];
        }
            break;
    }
}


#pragma mark - 更新布局
- (void)resizeSubviewSize {
    
    //视频
    if (self.item.type == AFBrowserItemTypeVideo) {
        _scrollView.hidden = YES;
        self.player.hidden = NO;
    }
    
    //图片
    else {
        [_player pause];
        _player.hidden = YES;
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
    if ([self.delegate respondsToSelector:@selector(singleTapAction)]) {
        [self.delegate singleTapAction];
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
    
    if (self.item.type != AFBrowserItemTypeVideo) return;

    // 播放视频
    if ([@(self.indexPath.item) isEqualToNumber:notification.object]) {
        [self.player play];
    }
    
    // 暂停视频
    else {
        [self.player pause];
        [self.player seekToTime:0.f];
    }
}


- (void)stopPlayer {
    [_player pause];
}


@end


