//
//  AFImageBrowserViewController.h
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFImageBrowserTransformer.h"
#import "AFImageBrowserItem.h"

@protocol AFImageBrowserDelegate <NSObject>
@optional;

/** 删除照片 */
- (void)deleteImageAtIndex:(NSInteger)index;

@end



@interface AFImageBrowserViewController : UIViewController

/** 代理 */
@property (weak, nonatomic) id<AFImageBrowserDelegate> delegate;

/** 图片分页显示类型 YES：分页控制器  NO：label显示 */
@property (nonatomic, assign) BOOL pageControlType;

/** 是否显示删除按钮，默认显示 */
@property (assign, nonatomic) BOOL showDeleteBtn;

/** 转场 */
@property (strong, nonatomic) AFImageBrowserTransformer            *transformer;

/** 当前选中的图片的index */
@property (assign, nonatomic) NSInteger                    currentIndex;


/**
 * 快速初始化方法
 * @param items 数组里的类型必须是相同的，支持图片（支持UIImage，NSString，NSURL）或视频（支持NSString、URL）
 * 如果想展示不同类型的数据（比如图片和视频混合浏览），请直接使用new初始化，再使用addItem:itemType方法来添加数据
 * @param itemType items的对应类型
 * @param index 当前要展示数组的第几项内容
 */
- (instancetype)initWithItems:(NSArray *)items type:(AFBrowserItemType)itemType selectedIndex:(NSInteger)index;

/** 添加数据
 * @param item 可以是图片（支持UIImage，NSString，NSURL）或视频（支持NSString、URL）
 * @param itemType item的对应类型
 */
- (void)addImage:(id)image;


- (void)addVideo:(id)video coverImage:(id)coverImage;

@end


