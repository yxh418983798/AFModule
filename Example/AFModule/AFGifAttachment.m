//
//  AFGifAttachment.m
//  AFModule_Example
//
//  Created by alfie on 2021/2/22.
//  Copyright © 2021 yxh418983798. All rights reserved.
//

#import "AFGifAttachment.h"

@implementation AFGifAttachment



//- (void)drawRect:(CGRect)rect {
//
//    if (self.attributedString) {
//
//        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)_attributedString);
//        if (!framesetter) return;
////        CGPathRef path = CGPathCreateWithRect(rect, &CGAffineTransformIdentity);
//        rect = UIEdgeInsetsInsetRect(rect, self.insets);
//        rect = CGRectStandardize(rect);
//        CGRect cgPathBox = rect;
//        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
//        CGPathRef path = CGPathCreateWithRect(rect, NULL);
//
//        // CTFrameRef
//        CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
//        if (!ctFrame) return;
//
//        CGContextRef context = UIGraphicsGetCurrentContext();
//
//        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);
//        CGContextConcatCTM(context, flipVertical);
//        CGContextSetTextDrawingMode(context, kCGTextFill);
//
//        // 获取CTFrame中的CTLine
//        CFArrayRef lines = CTFrameGetLines(ctFrame);
//        NSUInteger lineCount = CFArrayGetCount(lines);
//        CGPoint *origins = NULL;
//        if (lineCount > 0) {
//            origins = malloc(lineCount * sizeof(CGPoint));
//            if (origins == NULL) return;
//            CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), origins);
////            CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), origins);
//        }
//
//        // find touch begin index or touch end index
//        for (CFIndex i = 0; i < lineCount; ++i) {
//            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
//            CFArrayRef runs = CTLineGetGlyphRuns(line);
//            if (!runs || CFArrayGetCount(runs) == 0) continue;
//            for (CFIndex j = 0; j < CFArrayGetCount(runs); ++j) {
//                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
//                CGFloat ascent;
//                CGFloat descent;
//                CGFloat leading;
//                CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
//                CGFloat height = ascent + descent;
//
//                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringIndicesPtr(run)[0], NULL);
//                CGFloat x = origins[i].x + xOffset;
//                CGFloat y = origins[i].y - descent;
//
//                CGRect runBounds = CGRectMake(x, y, width, height);
//                if (touchPhase == UITouchPhaseBegan) {
//                    CGPoint mirrorPoint = CGPointFlipped(beginPoint, rect);
//                    if (CGRectContainsPoint(runBounds, mirrorPoint)) {
//                        beginIndex = CTLineGetStringIndexForPosition(line, mirrorPoint);
//                    }
//                } else if (touchPhase == UITouchPhaseEnded) {
//                    CGPoint mirrorPoint = CGPointFlipped(endPoint, rect);
//                    if (CGRectContainsPoint(runBounds, mirrorPoint)) {
//                        endIndex = CTLineGetStringIndexForPosition(line, mirrorPoint);
//                    }
//                }
//            }
//        }
//
//        // draw CTRun
//        for (CFIndex i = 0; i < CFArrayGetCount(lines); ++i) {
//            // 获取CTLine中的CTRun
//            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
//
//            CGFloat lineAscent;
//            CGFloat lineDescent;
//            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
//
//            CFArrayRef runs = CTLineGetGlyphRuns(line);
//            for (CFIndex j = 0; j < CFArrayGetCount(runs); ++j) {
//                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
//                CFRange range = CTRunGetStringRange(run);
//                CGContextSetTextPosition(context, origins[i].x, origins[i].y);
//
//                // 获取CTRun的属性
//                NSDictionary *attDic = (__bridge NSDictionary *)CTRunGetAttributes(run);
//                NSNumber *num = [attDic objectForKey:kCustomGlyphAttributeType];
//                if (num) {
//                    // 不管是绘制链接还是表情，我们都需要知道绘制区域的大小，所以我们需要计算下
//                    CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
//                    CGFloat height = lineAscent + lineDescent;
//
//                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringIndicesPtr(run)[0], NULL);
//                    CGFloat x = origins[i].x + xOffset;
//                    CGFloat y = origins[i].y - lineDescent;
//
//                    CGRect runBounds = CGRectMake(x, y, width, height);
//
//                    int type = [num intValue];
//                    // 如果是绘制链接,@,##
//                    if (CustomGlyphAttributeURL <= type && type <= CustomGlyphAttributeTopic) {
//                        // 先取出链接的文字范围，后算计算点击区域的时候要用
//                        NSValue *value = [attDic valueForKey:kCustomGlyphAttributeRange];
//                        NSRange _range = [value rangeValue];
//                        CFRange linkRange = CFRangeFromNSRange(_range);
//
//                        // 我们先绘制背景，不然文字会被背景覆盖
//                        if (touchPhase == UITouchPhaseBegan &&
//                             isTouchRange(beginIndex, linkRange, range)) { // 点击开始
//
//                            CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
//                            CGContextFillRect(context, runBounds);
//                        } else { // 点击结束
//                            BOOL isSameRange = NO;
//                            if (isTouchRange(beginIndex, linkRange, range)) { // 如果点击区域落在链接区域内
//                                CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
//                                CGContextFillRect(context, runBounds);
//                                // beginIndex & endIndex in the same range
//                                isSameRange = isTouchRange(endIndex, linkRange, range);
//                            }
//
//                            CGPoint mirrorPoint = CGPointFlipped(endPoint, rect);
//                            if (touchPhase == UITouchPhaseEnded &&
//                                CGRectContainsPoint(runBounds, mirrorPoint) &&
//                                isSameRange) {
//
//                                if (type == CustomGlyphAttributeURL) {
//                                    if ([_delegate respondsToSelector:@selector(touchedURLWithURLStr:)]) {
//                                        [_delegate touchedURLWithURLStr:[self.attributedString.string substringWithRange:_range]];
//                                    }
//                                } else if (type == CustomGlyphAttributeAt) {
//                                    if ([_delegate respondsToSelector:@selector(touchedURLWithAtStr:)]) {
//                                        [_delegate touchedURLWithAtStr:[self.attributedString.string substringWithRange:_range]];
//                                    }
//                                } else if (type == CustomGlyphAttributeTopic) {
//                                    if ([_delegate respondsToSelector:@selector(touchedURLWithTopicStr:)]) {
//                                        [_delegate touchedURLWithTopicStr:[self.attributedString.string substringWithRange:_range]];
//                                    }
//                                } else {
//                                    NSAssert(NO, @"no this type");
//                                }
//                            }
//                        }
//
//                        // 这里需要绘制下划线，记住CTRun是不会自动绘制下滑线的
//                        // 即使你设置了这个属性也不行
//                        // CTRun.h中已经做出了相应的说明
//                        // 所以这里的下滑线我们需要自己手动绘制
//                        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
//                        CGContextSetLineWidth(context, 0.5);
//                        CGContextMoveToPoint(context, runBounds.origin.x, runBounds.origin.y);
//                        CGContextAddLineToPoint(context, runBounds.origin.x + runBounds.size.width, runBounds.origin.y);
//                        CGContextStrokePath(context);
//
//                        // 绘制文字
//                        CTRunDraw(run, context, CFRangeMake(0, 0));
//                    } else if (type == CustomGlyphAttributeImage) { // 如果是绘制表情
//                        // 表情区域是不需要文字的，所以我们只进行图片的绘制
//                        NSString *imageName = [attDic objectForKey:kCustomGlyphAttributeImageName];
//                        UIImage *image = [UIImage imageNamed:imageName];
//                        CGContextDrawImage(context, runBounds, image.CGImage);
//                    }
//                } else { // 没有特殊处理的时候我们只进行文字的绘制
//                    CTRunDraw(run, context, CFRangeMake(0, 0));
//                }
//            }
//        }
//
//        CFRelease(framesetter);
//        CGPathRelease(path);
//        CFRelease(textFrame);
//    }
//
//}



//- (void)attachGifAttribute:(NSAttributedString *)attributedString {
//
//    NSString *string = attributedString.string;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
//    NSArray *resultArr = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
//    for (NSInteger i = resultArr.count - 1; i >= 0; i --) {
//        NSTextCheckingResult *result = resultArr[i];
//        NSString *subString = [string substringWithRange:NSMakeRange(result.range.location+1, result.range.length-2)];
//        if ([self isGifAttachment:subString]) {
//            // gif
//        } else {
//            // 静态图片
//            UIImage *image = [UIImage imageNamed:subString];
//            if (image) {
//                NSTextAttachment *attachment = [NSTextAttachment new];
//                attachment.image = image;
//                attachment.bounds = CGRectMake(0, -4, 22, 22);
//                NSAttributedString *attrImageStr = [NSAttributedString attributedStringWithAttachment:attachment];
//                [attributeString replaceCharactersInRange:result.range withAttributedString:attrImageStr];
//            }
//        }
//    }
//
//}
//
//
//- (BOOL)isGifAttachment:(NSString *)attachment {
//    if ([attachment isEqualToString:@"肌肉"]) {
//        return YES;
//    }
//    return NO;
//}



@end
