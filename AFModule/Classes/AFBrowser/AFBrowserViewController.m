//
//  AFBrowserViewController.m
//  AFWorkSpace
//
//  Created by alfie on 2019/7/9.
//  Copyright © 2019 Alfie. All rights reserved.
//

#import "AFBrowserViewController.h"
#import "AFBrowserCollectionViewCell.h"
#import "AFBrowserTransformer.h"
#import "UIView+AFExtension.h"

@interface AFBrowserViewController () <UICollectionViewDelegate, UICollectionViewDataSource, AFBrowserCollectionViewCellDelegate, AFBrowserPresentedTransformerDelegate, AFBrowserSourceTransformerDelegate>

/** 导航栏，用于开发者自定义导航栏样式 和 添加子视图 */
@property (strong, nonatomic) UIView                    *toolBar;

/** 退出按钮 */
@property (strong, nonatomic) UIButton                  *dismissBtn;

/** 删除按钮 */
@property (strong, nonatomic) UIButton                  *deleteBtn;

/** 选择按钮 */
@property (strong, nonatomic) UIButton                  *selectBtn;

/** 分页计数器 */
@property (nonatomic, strong) UIPageControl             *pageControl;

/** 分页计数（文本） */
@property (nonatomic, strong) UILabel                   *pageLabel;

/** collectionView */
@property (strong, nonatomic) UICollectionView          *collectionView;

/** 转场 */
@property (strong, nonatomic) AFBrowserTransformer *transformer;

/** 数据源 */
@property (strong, nonatomic) NSMutableArray <AFBrowserItem *> *items;

/** 显示、隐藏toolBar */
@property (assign, nonatomic) BOOL            showToolBar;

/** 记录最初的index */
@property (assign, nonatomic) NSInteger       originalIndex;

@end


@implementation AFBrowserViewController
static const CGFloat lineSpacing = 0.f; //间隔

#pragma mark - 生命周期
- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.transformer = [AFBrowserTransformer new];
        self.transformer.presentedDelegate = self;
        self.transformer.sourceDelegate = self;
        self.index = 0;
        self.hideSourceViewWhenTransition = YES;
        self.transitioningDelegate = self.transformer;
        self.showToolBar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self configSubViews];
    [self loadItems];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.originalIndex = self.index;
    self.transformer.type = self.items[self.index].type;
    AFBrowserCollectionViewCell *cell = (AFBrowserCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
    cell.player.showToolBar = self.showToolBar;

    //设置偏移量
    self.collectionView.contentOffset = CGPointMake(self.index * ([[UIScreen mainScreen] bounds].size.width+lineSpacing), 0);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AFBrowserUpdateVideoStatus" object:@(self.index)];
    
    // pageControl
    switch (self.pageControlType) {
        case AFPageControlTypeCircle:
            self.pageControl.hidden = NO;
            _pageLabel.hidden = YES;
            break;
            
        case AFPageControlTypeText:
            _pageControl.hidden = YES;
            self.pageLabel.hidden   = NO;
            break;
            
        default:
            _pageControl.hidden = YES;
            _pageLabel.hidden   = YES;
            break;
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.items[self.index].type == AFBrowserItemTypeVideo) {
        AFBrowserCollectionViewCell *cell = (AFBrowserCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
        [cell.player browserCancelDismiss];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
    if (self.items[self.index].type == AFBrowserItemTypeVideo) {
        AFBrowserCollectionViewCell *cell = (AFBrowserCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
        [cell.player browserWillDismiss];
    }
}


#pragma mark - 配置UI
- (void)configSubViews {

    // collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width+lineSpacing, [[UIScreen mainScreen] bounds].size.height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.collectionView = [[UICollectionView alloc] initWithFrame:(CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height)) collectionViewLayout:layout];
    [self.collectionView registerClass:[AFBrowserCollectionViewCell class] forCellWithReuseIdentifier:@"AFBrowserCollectionViewCell"];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator   = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
}

- (UIView *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIView alloc] initWithFrame:(CGRectMake(0, self.showToolBar ? 0 : -[UIApplication sharedApplication].statusBarFrame.size.height - 44.f, UIScreen.mainScreen.bounds.size.width, [UIApplication sharedApplication].statusBarFrame.size.height + 44.f))];
        _toolBar.backgroundColor = UIColor.whiteColor;
    }
    return _toolBar;
}

- (UIButton *)dismissBtn {
    if (!_dismissBtn) {
        _dismissBtn = [[UIButton alloc] initWithFrame:(CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 50, 44))];
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:self.class] URLForResource:@"AFModule" withExtension:@"bundle"]];
        [_dismissBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_imageBrowser_dismiss@2x" ofType:@".png"]] forState:(UIControlStateNormal)];
        [_dismissBtn addTarget:self action:@selector(dismissBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
        [self.toolBar addSubview:_dismissBtn];
    }
    return _dismissBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] initWithFrame:(CGRectMake(UIScreen.mainScreen.bounds.size.width - 50, [UIApplication sharedApplication].statusBarFrame.size.height, 50, 44))];
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:self.class] URLForResource:@"AFModule" withExtension:@"bundle"]];
        [_deleteBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_imageBrowser_delete@2x" ofType:@".png"]] forState:(UIControlStateNormal)];
        [_deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
        [self.toolBar addSubview:_deleteBtn];
    }
    return _deleteBtn;
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] initWithFrame:(CGRectMake(UIScreen.mainScreen.bounds.size.width - 50, [UIApplication sharedApplication].statusBarFrame.size.height, 50, 44))];
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:self.class] URLForResource:@"AFModule" withExtension:@"bundle"]];
        [_selectBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"af_imageBrowser_delete@2x" ofType:@".png"]] forState:(UIControlStateNormal)];
        [_selectBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
        [self.toolBar addSubview:_selectBtn];
    }
    return _selectBtn;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:(CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - ([UIApplication sharedApplication].statusBarFrame.size.height == 20 ? 30 : 45), [[UIScreen mainScreen] bounds].size.width, 20))];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.numberOfPages = self.items.count;
        _pageControl.currentPage = (NSInteger)self.index;
        [self.view addSubview:_pageControl];
    }
    return _pageControl;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, [[UIScreen mainScreen] bounds].size.width, 44))];
        _pageLabel.font = [UIFont boldSystemFontOfSize:16];
        _pageLabel.textColor = UIColor.blackColor;
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.text = [NSString stringWithFormat:@"%zd / %zd", self.index + 1, self.items.count];
        [self.toolBar addSubview:_pageLabel];
    }
    return _pageLabel;
}


#pragma mark - 设置浏览类型
- (void)setBrowserType:(AFBrowserType)browserType {
    if (_browserType != browserType) {
        _browserType = browserType;
        switch (_browserType) {
                
            case AFBrowserTypeDelete:
                [self.view addSubview:self.toolBar];
                [self.toolBar addSubview:self.deleteBtn];
                [self.toolBar addSubview:self.dismissBtn];
                break;
                
//            case AFBrowserTypeSelect:
//                [self.view addSubview:self.toolBar];
//                [self.toolBar addSubview:self.selectBtn];
//                [self.toolBar addSubview:self.dismissBtn];
//                break;
                
            default:
                if (self.toolBar.superview) [self.toolBar removeFromSuperview];
                if (_deleteBtn.superview) [_deleteBtn removeFromSuperview];
                if (_dismissBtn.superview) [_dismissBtn removeFromSuperview];
                break;
        }
    }
}


#pragma mark - 是否隐藏转场原视图
- (void)setHideSourceViewWhenTransition:(BOOL)hideSourceViewWhenTransition {
    _hideSourceViewWhenTransition = hideSourceViewWhenTransition;
    self.transformer.hideSourceViewWhenTransition = hideSourceViewWhenTransition;
}


#pragma mark - 添加数据
- (NSMutableArray<AFBrowserItem *> *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)addItem:(AFBrowserItem *)item {
    [self.items addObject:item];
}

- (void)loadItems {
    
    if (self.index != 0 && self.index != self.items.count - 1) return;
    if (![self.delegate respondsToSelector:@selector(dataForItemWithIdentifier:direction:)]) return;
    
    AFBrowserItem *item = [self.items objectAtIndex:self.index];
    id identifier = item.identifier;
    AFBrowserDirection direction = self.index == 0 ? AFBrowserDirectionLeft : AFBrowserDirectionRight;
    NSArray *items = [self.delegate dataForItemWithIdentifier:identifier direction:direction];
    if (direction == AFBrowserDirectionLeft) {
        for (int i = 0; i < items.count; i++) {
            [self.items insertObject:items[i] atIndex:0];
        }
        self.index = items.count;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
        [self.collectionView reloadData];
    } else {
        [self.items addObjectsFromArray:items];
        [self.collectionView reloadData];
    }
    _pageControl.numberOfPages = self.items.count;
}


#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AFBrowserItem *item = indexPath.item >= self.items.count ? self.items.lastObject : self.items[indexPath.item];
    AFBrowserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AFBrowserCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell attachItem:item atIndexPath:indexPath];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [[(AFBrowserCollectionViewCell *)cell scrollView] setZoomScale:1.0];
}


#pragma mark - 监听滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        
        int currentPageNum = round(scrollView.contentOffset.x / (scrollView.frame.size.width + lineSpacing));
        switch (self.pageControlType) {
                
            case AFPageControlTypeCircle:
                self.pageControl.currentPage = currentPageNum;
                break;
                
            case AFPageControlTypeText:
                self.pageLabel.text = [NSString stringWithFormat:@"%d / %zd", currentPageNum + 1, self.items.count];
                break;
                
            default:
                break;
        }
        self.index = currentPageNum;
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadItems];
    self.transformer.type = self.items[self.index].type;
    AFBrowserCollectionViewCell *cell = (AFBrowserCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
    [UIView animateWithDuration:0.25 animations:^{
        cell.player.showToolBar = self.showToolBar;
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AFBrowserUpdateVideoStatus" object:@(self.index)];
}


#pragma mark - 单击图片 AFBrowserCollectionViewCellDelegate
- (void)singleTapAction {
    switch (self.browserType) {
            
        case AFBrowserTypeDefault:
            [self dismissBtnAction];
            break;
            
        default:
            //隐藏
            _showToolBar = !_showToolBar;
            [UIView animateWithDuration:0.25 animations:^{
                self.toolBar.y = self.showToolBar ? 0 : -[UIApplication sharedApplication].statusBarFrame.size.height - 44.f;
                if (self.items[self.index].type == AFBrowserItemTypeVideo) {
                    AFBrowserCollectionViewCell *cell = (AFBrowserCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
                    cell.player.showToolBar = self.showToolBar;
                }
//                self.pageControl.y = UIScreen.mainScreen.bounds.size.height;
//                [self setNeedsStatusBarAppearanceUpdate];
            }];
            break;
    }
}


#pragma mark - 退出
- (void)dismissBtnAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 删除图片、视频
- (void)deleteBtnAction {
    
    if ([self.delegate respondsToSelector:@selector(deleteImageAtIndex:)]) {
        [self.delegate deleteImageAtIndex:self.index];
    }
    
    AFBrowserCollectionViewCell *cell = (AFBrowserCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
    [cell.player stop];
    if (self.items.count == 1) {
        self.transformer.userDefaultAnimation = YES;
        [self dismissBtnAction];
        return;
    }
    
    [self.items removeObjectAtIndex:self.index];
    _pageControl.numberOfPages --;
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.index inSection:0]]];
    [self scrollViewDidScroll:self.collectionView];
}


#pragma mark - 选择图片
- (void)selectBtnAction {
    
}


#pragma mark -- AFBrowserPresentedTransformerDelegate
- (UIView *)transitionViewForPresentedController {
    AFBrowserCollectionViewCell *cell = (AFBrowserCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
    AFBrowserItem *item = self.items[self.index];
    if (item.type == AFBrowserItemTypeImage) {
        return cell.imageView;
    }
    return cell.player;
}

- (CGRect)frameForPresentedController {
    return self.transitionViewForPresentedController.frame;
}

- (UIImageView *)transitionViewForSourceController {
    
    if (![self.delegate respondsToSelector:@selector(browser:viewForTransitionAtIndex:)]) return nil;
    UIView *transitionView = [self.delegate browser:self viewForTransitionAtIndex:self.index];
    if (!transitionView) {
        transitionView = [self.delegate browser:self viewForTransitionAtIndex:MIN(self.originalIndex, self.items.count - 1)];
    }
    if ([transitionView isKindOfClass:UIImageView.class]) {
        return (UIImageView *)transitionView;
    }
    if ([self.delegate respondsToSelector:@selector(browser:imageForTransitionAtIndex:)]) {
        return [[UIImageView alloc] initWithImage:[self.delegate browser:self imageForTransitionAtIndex:self.index]];
    }
    return nil;
}

- (CGRect)frameForSourceController {

    UIView *transitionView = [self.delegate browser:self viewForTransitionAtIndex:self.index];
    if (!transitionView) {
        transitionView = [self.delegate browser:self viewForTransitionAtIndex:MIN(self.originalIndex, self.items.count - 1)];
    }
    UIView *toView;
    for (UIView *view = transitionView; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            toView = [(UIViewController *)nextResponder view].superview;
        }
    }
    return [transitionView.superview convertRect:transitionView.frame toView:toView ?: transitionView.window];
}



@end




