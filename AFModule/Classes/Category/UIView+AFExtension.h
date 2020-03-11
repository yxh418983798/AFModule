//
//  UIView+AFExtension.h
//  AFModule
//
//  Created by alfie on 2020/3/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (AFExtension)

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGSize  size;
@property (assign, nonatomic) CGPoint origin;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
- (CGFloat)maxX;
- (CGFloat)midX;
- (CGFloat)minX;
- (CGFloat)maxY;
- (CGFloat)midY;
- (CGFloat)minY;

@end

NS_ASSUME_NONNULL_END
