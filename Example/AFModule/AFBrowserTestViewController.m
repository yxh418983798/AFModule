//
//  AFBrowserTestViewController.m
//  AFModule_Example
//
//  Created by alfie on 2020/3/6.
//  Copyright © 2020 yxh418983798. All rights reserved.
//

#import "AFBrowserTestViewController.h"
#import "UIView+AFExtension.h"
#import "AFBrowserViewController.h"
#import "UIImageView+WebCache.h"

@interface AFBrowserTestViewController () <UITableViewDelegate, UITableViewDataSource, AFBrowserDelegate>

/** tableView */
@property (strong, nonatomic) UITableView            *tableView;

@end

@implementation AFBrowserTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;

    self.tableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, 88, self.view.width, self.view.height)) style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}



#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    UIImageView *imgView;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"UITableViewCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"第%lu个Cell", indexPath.row];
        imgView = [UIImageView new];
        imgView.tag = 2;
        imgView.frame = CGRectMake(10, 10, 100, 100);
        [cell addSubview:imgView];
    } else {
        imgView = [cell viewWithTag:2];
    }
    [imgView sd_setImageWithURL:[NSURL URLWithString:@"http://img.qiyejiaoyou.com/99fc5f5b18d87584a9929fa195d1df17"]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AFBrowserViewController *browserVc = [AFBrowserViewController new];
    browserVc.index = indexPath.row;
//    browserVc.browserType = AFBrowserTypeDelete;
//    browserVc.pageControlType = AFPageControlTypeText;
    browserVc.delegate = self;
    
//    [browserVc addItem:[AFBrowserItem browserItem:@"http://img.qiyejiaoyou.com/99fc5f5b18d87584a9929fa195d1df17" coverImage:@"http://img.qiyejiaoyou.com/7ffab8f32c94c4a5320d6e232a0cd8b8" type:(AFBrowserItemTypeImage) identifier:nil]];
//    [browserVc addItem:[AFBrowserItem browserItem:@"http://img.qiyejiaoyou.com/99fc5f5b18d87584a9929fa195d1df17" coverImage:@"http://img.qiyejiaoyou.com/7ffab8f32c94c4a5320d6e232a0cd8b8" type:(AFBrowserItemTypeImage) identifier:nil]];
//    [browserVc addItem:[AFBrowserItem browserItem:@"http://img.qiyejiaoyou.com/99fc5f5b18d87584a9929fa195d1df17" coverImage:@"http://img.qiyejiaoyou.com/7ffab8f32c94c4a5320d6e232a0cd8b8" type:(AFBrowserItemTypeImage) identifier:nil]];
//    [browserVc addItem:[AFBrowserItem browserItem:@"http://img.qiyejiaoyou.com/99fc5f5b18d87584a9929fa195d1df17" coverImage:@"http://img.qiyejiaoyou.com/7ffab8f32c94c4a5320d6e232a0cd8b8" type:(AFBrowserItemTypeImage) identifier:nil]];
//    [browserVc addItem:[AFBrowserItem browserItem:@"http://img.qiyejiaoyou.com/99fc5f5b18d87584a9929fa195d1df17" coverImage:@"http://img.qiyejiaoyou.com/7ffab8f32c94c4a5320d6e232a0cd8b8" type:(AFBrowserItemTypeImage) identifier:nil]];
    
    [browserVc addItem:[AFBrowserItem imageItem:@"http://img.qiyejiaoyou.com/99fc5f5b18d87584a9929fa195d1df17" coverImage:@"http://img.qiyejiaoyou.com/7ffab8f32c94c4a5320d6e232a0cd8b8" identifier:nil]];

    [browserVc addItem:[AFBrowserItem videoItem:@"http://vid.qiyejiaoyou.com/fc1521ccd505da5154874b85149295af" coverImage:@"http://img.qiyejiaoyou.com/7ffab8f32c94c4a5320d6e232a0cd8b8" duration:0 identifier:nil]];
    [browserVc addItem:[AFBrowserItem videoItem:@"http://vid.qiyejiaoyou.com/fc1521ccd505da5154874b85149295af" coverImage:@"http://img.qiyejiaoyou.com/7ffab8f32c94c4a5320d6e232a0cd8b8" duration:0 identifier:nil]];
    [self presentViewController:browserVc animated:YES completion:nil];
    

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}



#pragma mark -- 浏览图片 AFBrowserSourceTransformerDelegate
- (UIImageView *)browser:(AFBrowserViewController *)browser viewForTransitionAtIndex:(NSInteger)index {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return [cell viewWithTag:2];
}


@end
