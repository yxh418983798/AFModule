//
//  AFLabel.m
//  AFModule_Example
//
//  Created by alfie on 2021/2/20.
//  Copyright © 2021 yxh418983798. All rights reserved.
//

#import "AFLabel.h"
#import <CoreText/CoreText.h>
#import "YYTextInput.h"
#import "YYTextContainerView.h"
#import "YYTextSelectionView.h"
#import "YYTextMagnifier.h"
#import "YYTextEffectWindow.h"
#import "YYTextKeyboardManager.h"
#import "YYTextUtilities.h"
#import "YYTextTransaction.h"
#import "YYTextWeakProxy.h"
#import "NSAttributedString+YYText.h"
#import "UIPasteboard+YYText.h"
#import "UIView+YYText.h"

static NSString *pattern = @"\\[.*?\\]";


@interface AFLabel ()

/** 富文本 */
@property (nonatomic, strong) NSMutableAttributedString            *attributedString;

@property (nonatomic, assign) UIEdgeInsets            insets;



@end

@implementation AFLabel


- (void)setAttributedText:(NSAttributedString *)attributedText {
    self.attributedString = attributedText;
    [self setNeedsDisplay];
}



- (void)drawTextInRect:(CGRect)rect {

    if (self.attributedString) {

        // CTFramesetterRef
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)_attributedString);
        if (!framesetter) return;
        rect = UIEdgeInsetsInsetRect(rect, self.insets);
        rect = CGRectStandardize(rect);
        CGRect cgPathBox = rect;
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
        CGPathRef path = CGPathCreateWithRect(rect, NULL);
//        CGPathRef path = CGPathCreateWithRect(rect, &CGAffineTransformIdentity);

        // CTFrameRef
        CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        if (!ctFrame) return;

        // context
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        {
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextTranslateCTM(context, 0.f, rect.size.height);
            CGContextScaleCTM(context, 1.f, -1.f);
            CFRange textRange = CFRangeMake(0, (CFIndex)[self.attributedString length]);
            
            // CTLine
            CFArrayRef lines = CTFrameGetLines(ctFrame);
            NSUInteger lineCount = CFArrayGetCount(lines);
            CGPoint *origins = NULL;
            if (lineCount > 0) {
                origins = malloc(lineCount * sizeof(CGPoint));
                if (origins == NULL) return;
                CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), origins);
    //            CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), origins);
            }

            // CTRun
            for (CFIndex i = 0; i < lineCount; ++i) {
                CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                CFArrayRef runs = CTLineGetGlyphRuns(line);
                if (!runs || CFArrayGetCount(runs) == 0) continue;
                for (CFIndex j = 0; j < CFArrayGetCount(runs); ++j) {
                    // CTRun
                    CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                    CGFloat ascent;
                    CGFloat descent;
                    CGFloat leading;
                    CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
                    CGFloat height = ascent + descent;

                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringIndicesPtr(run)[0], NULL);
                    CGFloat x = origins[i].x + xOffset;
                    CGFloat y = origins[i].y - descent;
                    CTRunDraw(run, context, CFRangeMake(0, 0));


//                    CGRect runBounds = CGRectMake(x, y, width, height);
//                    if (touchPhase == UITouchPhaseBegan) {
//                        CGPoint mirrorPoint = CGPointFlipped(beginPoint, rect);
//                        if (CGRectContainsPoint(runBounds, mirrorPoint)) {
//                            beginIndex = CTLineGetStringIndexForPosition(line, mirrorPoint);
//                        }
//                    } else if (touchPhase == UITouchPhaseEnded) {
//                        CGPoint mirrorPoint = CGPointFlipped(endPoint, rect);
//                        if (CGRectContainsPoint(runBounds, mirrorPoint)) {
//                            endIndex = CTLineGetStringIndexForPosition(line, mirrorPoint);
//                        }
//                    }
                }
            }
            
        }
        CGContextRestoreGState(context);
            CFRelease(framesetter);
            CGPathRelease(path);
            CFRelease(ctFrame);
    }

}







//- (void)setAttributedText:(NSAttributedString *)attributedText {
//
//    NSString *string = attributedText.string;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
//    NSArray *resultArr = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
//    for (NSInteger i = resultArr.count - 1; i >= 0; i --) {
//        NSTextCheckingResult *result = resultArr[i];
//        NSString *subString = [string substringWithRange:NSMakeRange(result.range.location+1, result.range.length-2)];
//
//        if ([self isGifAttachment:subString]) {
//            // gif
//
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
