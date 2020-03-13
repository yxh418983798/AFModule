//
//  AFBrowserViewController.h
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFBrowserItem.h"

/**
 * 浏览模式
 */
typedef NS_ENUM(NSUInteger, AFBrowserType){
    AFBrowserTypeDefault,  // 浏览模式，没有操作
//    AFBrowserTypeSelect,   // 选择模式，可以选中图片
    AFBrowserTypeDelete,   // 删除模式，可以删除图片
};


/**
 * 显示页码的方式
 */
typedef NS_ENUM(NSUInteger, AFPageControlType){
    AFPageControlTypeNone,    // 不显示页码
    AFPageControlTypeCircle,  // 小圆点
    AFPageControlTypeText,    // 文字
};


/**
 * 翻页的方向
 */
typedef NS_ENUM(NSUInteger, AFBrowserDirection){
    AFBrowserDirectionLeft,   // 向左翻页
    AFBrowserDirectionRight,  // 向右翻页
};


@class AFBrowserViewController;
@protocol AFBrowserDelegate <NSObject>

/**
 * 转场的View，如果返回的是ImageView，则只需要实现该方法就能实现转场动画
 * 如果不是ImageView，请实现imageForTransitionAtIndex返回一张图片
 */
- (UIView *)browser:(AFBrowserViewController *)browser viewForTransitionAtIndex:(NSInteger)index;

@optional;

/**
 * 转场图片
 */
- (UIImage *)browser:(AFBrowserViewController *)browser imageForTransitionAtIndex:(NSInteger)index;


/**
 * 删除照片的回调
 */
- (void)deleteImageAtIndex:(NSInteger)index;


/**
 * 分页加载数据，每次浏览到第一个或最后一个Item时，自动调用该方法获取数据
 * 如果图片数据量很大，建议实现该协议来分页加载数据源，以提升性能
 * 实现该方法后，addItem：添加的数据 将会无效，AFBrowser会从该协议返回的数据来展示
 *
 * @param identifier 标识符
 * 一般是数据库表的主键或某个索引，也可以是自定义的其他数据类型，用于标记来获取对应的数据
 * 当第一次获取数据时，identifier是空的
 * 当向左翻页时，identifier返回当前数组第一个Item的identifier
 * 当向右翻页时，identifier返回当前数据最后一个Item的identifier
 *
 * @param direction  翻页方向
 * @result           返回一组AFBrowserItem实例
 */
- (NSArray<AFBrowserItem *> *)dataForItemWithIdentifier:(id)identifier direction:(AFBrowserDirection)direction;

@end



@interface AFBrowserViewController : UIViewController

/** 代理 */
@property (weak, nonatomic) id<AFBrowserDelegate>      delegate;

/** 当前选中的图片的index */
@property (assign, nonatomic) NSInteger                index;

/** 浏览模式 */
@property (assign, nonatomic) AFBrowserType            browserType;

/** 页码显示类型，默认不显示 */
@property (nonatomic, assign) AFPageControlType        pageControlType;

/** 转场时，是否隐藏源视图，默认YES */
@property (assign, nonatomic) BOOL                     hideSourceViewWhenTransition;

/** 导航栏，用于开发者自定义导航栏样式 和 添加子视图 */
- (UIView *)toolBar;

/** 退出按钮 */
- (UIButton *)dismissBtn;

/** 删除按钮 */
- (UIButton *)deleteBtn;

/** 选择按钮 */
- (UIButton *)selectBtn;

/** 分页计数器 */
- (UIPageControl *)pageControl;

/** 分页计数（文本） */
- (UILabel *)pageLabel;


/**
 * 添加数据
 *
 * @param item   图片或视频类型的AFBrowserItem
 */
- (void)addItem:(AFBrowserItem *)item;


@end


