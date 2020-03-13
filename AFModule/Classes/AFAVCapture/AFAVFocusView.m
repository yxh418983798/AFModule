//
//  AFVideoFocusView.m
//  AFModule
//
//  Created by alfie on 2020/3/12.
//

#import "AFAVFocusView.h"

@interface AFAVFocusView ()

/** 路径 */
@property (nonatomic, strong) UIBezierPath *path;

@end


@implementation AFAVFocusView

#pragma mark - 构造
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.path = [UIBezierPath bezierPath];
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    self.path = [UIBezierPath bezierPathWithRect:self.bounds];
    self.path.lineCapStyle = kCGLineCapButt;
    self.path.lineWidth = 2.0;
    UIColor *color = [UIColor colorWithRed:45/255.0 green:175/255.0 blue:45/255.0 alpha:1];
    [color set];
    
    // 路径
    [self.path moveToPoint:CGPointMake(rect.size.width / 2.0, 0)];
    [self.path addLineToPoint:CGPointMake(rect.size.width / 2.0, 8)];
    [self.path moveToPoint:CGPointMake(0, rect.size.width / 2.0)];
    [self.path addLineToPoint:CGPointMake(8, rect.size.width / 2.0)];
    [self.path moveToPoint:CGPointMake(rect.size.width / 2.0, rect.size.height)];
    [self.path addLineToPoint:CGPointMake(rect.size.width / 2.0, rect.size.height - 8)];
    [self.path moveToPoint:CGPointMake(rect.size.width, rect.size.height / 2.0)];
    [self.path addLineToPoint:CGPointMake(rect.size.width - 8, rect.size.height / 2.0)];
    [self.path stroke];
}

@end

