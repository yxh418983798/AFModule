//
//  AFNavigationTitleViewController.m
//  AFModule_Example
//
//  Created by alfie on 2020/7/16.
//  Copyright © 2020 yxh418983798. All rights reserved.
//

#import "AFNavigationTitleViewController.h"

@interface AFNavigationTitleViewController () <UITableViewDelegate, UITableViewDataSource>

/** tableView */
@property (nonatomic, strong) UITableView                *tableView;

@end

@implementation AFNavigationTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"测试标题";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    [self configurationSubviews];
    
    
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
}





#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"UITableViewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    return cell;
}


@end
