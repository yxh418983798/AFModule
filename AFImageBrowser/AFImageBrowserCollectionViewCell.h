//
//  AFImageBrowserCollectionViewCell.h
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol AFImageBrowserCollectionViewCellDelegate <NSObject>

/** 单击事件 */
- (void)singleTap;

@end


@interface AFImageBrowserCollectionViewCell : UICollectionViewCell

/** 代理 */
@property (weak, nonatomic) id<AFImageBrowserCollectionViewCellDelegate> delegate;

@property (nonatomic, strong) UIScrollView  *scrollView;

@property (nonatomic, strong) UIImageView   *imageView;

/** 视频播放容器 */
@property (strong, nonatomic) UIView        *playerView;

//绑定数据
- (void)attachItem:(id)item atIndexPath:(NSIndexPath *)indexPath;

//滑动时 更新视频状态
- (void)updateVideoStatus;

@end


