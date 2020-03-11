//
//  AFKVOViewController.m
//  AFModule_Example
//
//  Created by alfie on 2019/12/6.
//  Copyright © 2019 yxh418983798. All rights reserved.
//

//#import "AFKVOViewController.h"
//#import "KVOModule.h"
//#import "NSObject+KVOModule.h"
//
//@interface AFKVOViewController () {
//    NSString *_name;
//}
//
///** name */
//@property (strong, nonatomic) NSString            *name;
//
//@end
//
//@implementation AFKVOViewController
//
//static KVOModule *kvo;
//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    kvo = self.KVO;
//    [self addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:nil];
//    [self addObserver:self.KVO forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:nil];
//
//    self.name = @"1";
//    _name = @"2";
//    [self setValue:@"3" forKey:@"name"];
//    [self setValue:@"4" forKey:@"_name"];
//    [self setValue:@"5" forKey:@"Name"];
//
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"哈哈" style:(UIBarButtonItemStylePlain) target:self action:@selector(remove)];
//}
//
//
//- (void)remove {
//    [self removeObserver:self forKeyPath:@"name"];
//    self.name = @"1";
//}
//
//
//- (void)dealloc {
//    NSLog(@"-------------------------- 是否 --------------------------");
//}
//
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    NSLog(@"-------------------------- 改变：%@ --------------------------", change[NSKeyValueChangeNewKey]);
//}
//
//
//@end
