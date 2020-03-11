//
//  AFImageBrowserViewController.m
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "AFImageBrowserViewController.h"
#import "AFImageBrowserCollectionViewCell.h"

@interface AFImageBrowserViewController () <UICollectionViewDelegate, UICollectionViewDataSource, AFImageBrowserCollectionViewCellDelegate, AFImageBrowserPresentedTransformerDelegate>

/** 导航栏 */
@property (strong, nonatomic) UIView              *naviView;

/** 删除按钮 */
@property (strong, nonatomic) UIButton              *deleteBtn;

/** 分页计数器 */
@property (nonatomic, strong) UIPageControl *pageControl;

/** 分页计数（文本） */
@property (nonatomic, strong) UILabel *pageLabel;

/** 数据源 */
@property (strong, nonatomic) NSMutableArray <AFImageBrowserItem *>              *items;

/** collectionView */
@property (strong, nonatomic) UICollectionView            *collectionView;
@end


@implementation AFImageBrowserViewController

static const CGFloat lineSpacing = 20.f; //间隔

#pragma mark - 生命周期
- (instancetype)init {
    self = [super init];
    if (self) {
        self.transformer = [AFImageBrowserTransformer new];
        self.transformer.presentedDelegate = self;
        self.transformer.index = index;
        self.transitioningDelegate = self.transformer;
        self.currentIndex  = 0;
    }
    return self;
}

- (instancetype)initWithItems:(NSArray *)items type:(AFBrowserItemType)itemType selectedIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        
        self.transformer = [AFImageBrowserTransformer new];
        self.transformer.presentedDelegate = self;
        self.transformer.index = index;
        self.transitioningDelegate = self.transformer;
        
        for (id item in items) {
            AFImageBrowserItem *itemModel = [AFImageBrowserItem new];
            itemModel.image = item;
            itemModel.type = itemType;
            [self.items addObject:itemModel];
        }
        self.currentIndex  = index;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    self.pageControlType = YES;
    self.showDeleteBtn   = YES;
    
    //UI
    self.pageControl.numberOfPages = self.items.count;
    self.pageControl.currentPage = (NSInteger)self.currentIndex;
    self.pageLabel.text = [NSString stringWithFormat:@"%zd / %zd", _pageControl.currentPage + 1, _pageControl.numberOfPages];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width+lineSpacing, [[UIScreen mainScreen] bounds].size.height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:(CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height)) collectionViewLayout:layout];
    [self.collectionView registerClass:[AFImageBrowserCollectionViewCell class] forCellWithReuseIdentifier:@"AFImageBrowserCollectionViewCell"];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator   = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //设置偏移量
    self.collectionView.contentOffset = CGPointMake(self.currentIndex * ([[UIScreen mainScreen] bounds].size.width+lineSpacing), 0);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AFImageBrowserUpdateVideoStatus" object:@(self.currentIndex)];
}



#pragma mark - 数据
- (NSMutableArray<AFImageBrowserItem *> *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}


- (void)addImage:(id)image {
    AFImageBrowserItem *model = [AFImageBrowserItem new];
    model.image = image;
    model.type = AFBrowserItemTypeImageUrl;
    [self.items addObject:model];
}

- (void)addVideo:(id)video coverImage:(id)coverImage {
    AFImageBrowserItem *model = [AFImageBrowserItem new];
    model.video = video;
    model.image = coverImage;
    model.type = AFBrowserItemTypeVideoUrl;
    [self.items addObject:model];
}



#pragma mark - setter方法
//设置pageType的显示方式
- (void)setPageControlType:(BOOL)pageControlType {
    if (_pageControlType != pageControlType) {
        _pageControlType  = pageControlType;
        self.pageControl.hidden = !pageControlType;
        self.pageLabel.hidden   = pageControlType;
    }
}

//显示、隐藏删除按钮
- (void)setShowDeleteBtn:(BOOL)showDeleteBtn {
    _showDeleteBtn = showDeleteBtn;
    _deleteBtn.hidden = !showDeleteBtn;
}


//- (void)setNavi {
//
//    _naviView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, XH_Width, Navi_H))];
//    _naviView.backgroundColor = RGBAColor(30, 31, 34, 1);
//    [self.view addSubview:_naviView];
//
//    //退出按钮
//    UIButton *dismissBtn = [[UIButton alloc] initWithFrame:(CGRectMake(0, 20, 50, 44))];
//    [dismissBtn setImage:[UIImage imageNamed:@"箭头-左-白"] forState:(UIControlStateNormal)];
//    [dismissBtn setTitleColor:BaseColor forState:UIControlStateNormal];
//    [dismissBtn addTarget:self action:@selector(dismiss) forControlEvents:(UIControlEventTouchUpInside)];
//    [_naviView addSubview:dismissBtn];
//
//    //删除按钮
//    _deleteBtn = [[XHButton alloc] initWithFrame:(CGRectMake(XH_Width - 50, 20, 50, 44))];
//    [_deleteBtn setImage:[UIImage imageNamed:@"删除-垃圾箱-白"] forState:(UIControlStateNormal)];
//    _deleteBtn.imageFrame = CGRectMake(15, 12, 20, 20);
//    _deleteBtn.tintColor = [UIColor whiteColor];
//    [_deleteBtn setTitleColor:BaseColor forState:UIControlStateNormal];
//    [_deleteBtn addTarget:self action:@selector(deleteImage) forControlEvents:(UIControlEventTouchUpInside)];
//    [_naviView addSubview:_deleteBtn];
//}



#pragma mark - 懒加载
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:(CGRectMake(0, self.view.height - 30, [[UIScreen mainScreen] bounds].size.width, 20))];
        _pageControl.userInteractionEnabled = NO;
        [self.view addSubview:_pageControl];
    }
    return _pageControl;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, self.view.height - 54, [[UIScreen mainScreen] bounds].size.width, 44))];
        _pageLabel.font = [UIFont boldSystemFontOfSize:16];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_pageLabel];
    }
    return _pageLabel;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AFImageBrowserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AFImageBrowserCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell attachItem:self.items[indexPath.item] atIndexPath:indexPath];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [[(AFImageBrowserCollectionViewCell *)cell scrollView] setZoomScale:1.0];
}



#pragma mark - 监听滚动
// 监听scrollView的滚动事件， 判断当前页数
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        int currentPageNum = round(scrollView.contentOffset.x / (scrollView.frame.size.width + lineSpacing));
        self.pageControl.currentPage = currentPageNum;
        self.pageLabel.text = [NSString stringWithFormat:@"%zd / %zd", _pageControl.currentPage + 1, _pageControl.numberOfPages];
        self.currentIndex = currentPageNum;
        self.transformer.index = currentPageNum;
        MOLog(@"-------------------------- 滚动%g size:%g--------------------------", scrollView.contentOffset.x, scrollView.contentSize.width);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AFImageBrowserUpdateVideoStatus" object:@(self.currentIndex)];
    }
}



#pragma mark - XHPhotoCollectionViewCellDelegate
//显示/隐藏视图
- (void)singleTap {
    [self dismiss];
    //    //隐藏
    //    if (_naviView.y == 0) {
    //        [UIView animateWithDuration:0.3 animations:^{
    //            _naviView.y = -XH_Navi_H;
    //            _pageLabel.y = XH_Height;
    //            _pageControl.y = XH_Height;
    //            [self setNeedsStatusBarAppearanceUpdate];
    //        }];
    //    }
    //    //显示
    //    else {
    //        [UIView animateWithDuration:0.3 animations:^{
    //            _naviView.y = 0;
    //            _pageControl.y = self.view.height - 30;
    //            _pageLabel.y   = self.view.height - 54;
    //            [self setNeedsStatusBarAppearanceUpdate];
    //        }];
    //    }
}


/** 返回状态栏style */
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


/* 返回状态栏隐藏动画模式 */
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}


/* 返回状态栏是否隐藏 */
- (BOOL)prefersStatusBarHidden {
    return self.naviView.y != 0;
}



#pragma mark - 点击事件
//退出
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//删除图片
- (void)deleteImage {
    NSInteger index = self.pageControl.currentPage;
    
    if ([self.delegate respondsToSelector:@selector(deleteImageAtIndex:)]) {
        [self.delegate deleteImageAtIndex:index];
    }
    
    if (self.items.count == 1) {
        [self.items removeObjectAtIndex:0];
        [self dismiss];
        return;
    }
    
    [self.items removeObjectAtIndex:index];
    self.pageControl.numberOfPages --;
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    [self scrollViewDidScroll:self.collectionView];
}



#pragma mark -- AFImageBrowserPresentedTransformerDelegate
- (UIView *)transformer:(AFImageBrowserTransformer *)transformer transitionViewForPresentedControllerAtIndex:(NSInteger)index {
    AFImageBrowserCollectionViewCell *cell = (AFImageBrowserCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.imageView;
}



@end




