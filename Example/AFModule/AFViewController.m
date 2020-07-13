//
//  AFViewController.m
//  AFModule
//
//  Created by yxh418983798 on 11/27/2019.
//  Copyright (c) 2019 yxh418983798. All rights reserved.
//

#import "AFViewController.h"
#import "AFTextModuleViewController.h"
#import "AFTimerViewController.h"
#import "AFKVOViewController.h"
//#import "AFBrowserTestViewController.h"
//#import "AFAVCaptureViewController.h"
//#import "AFAVEditViewController.h"

@interface AFViewController () <UITableViewDelegate, UITableViewDataSource>

/** tableView */
@property (nonatomic, strong) UITableView                *tableView;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray             *dataSource;

@end

@implementation AFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configurationSubviews];
    
    self.dataSource = [NSMutableArray array];
    [self addDataWithText:@"AFTextModule" class:@"AFTextModuleViewController"];
    [self addDataWithText:@"AFTimer" class:@"AFTimerViewController"];
    [self addDataWithText:@"KVO" class:@"AFKVOViewController"];
    [self addDataWithText:@"AFImageBrowser" class:@"AFBrowserTestViewController"];
    [self addDataWithText:@"AFAVCapture" class:@"AFAVCaptureViewController"];

    
//    AFAVCaptureViewController *avCaptureVC = [AFAVCaptureViewController new];
//    // 设置代理
//    avCaptureVC.delegate = self;
//    // 设置拍摄行为，默认是同时支持摄像和拍照，如果要求只能摄像，则设置如下
//    avCaptureVC.captureOption = AFAVCaptureOptionAV;
//    // 设置确认图片视频后，自动保存到本地相册
//    avCaptureVC.saveToAlbumEnable = YES;
//    // 设置摄像的最长时间为100秒，默认是15秒
//    avCaptureVC.maxDuration = 100;
//    // 跳转
//    [self presentViewController:avCaptureVC animated:YES completion:nil];
    
}


- (void)addDataWithText:(NSString *)text class:(NSString *)className {
    NSDictionary *data = @{
                           @"text" : text,
                           @"class" : className
                           };
    [self.dataSource addObject:data];
}



#pragma mark - UI
- (void)configurationSubviews {

    self.tableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, 88, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - 88)) style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 10)];
    self.tableView.rowHeight = 45;
    self.tableView.sectionFooterHeight = 0.001;
    self.tableView.sectionHeaderHeight = 0.001;
    
    self.tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
}





#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"UITableViewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *data = self.dataSource[indexPath.row];
    cell.textLabel.text = [data valueForKey:@"text"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:[NSClassFromString([data valueForKey:@"class"]) new] animated:YES];
}



@end
