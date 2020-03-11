//
//  AFImageBrowserItem.h
//  MostOne
//
//  Created by alfie on 2019/11/5.
//  Copyright © 2019 MostOne. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AFBrowserItemType) {
    AFBrowserItemTypeUIImage,   // UIImage
    AFBrowserItemTypeImageName, // 本地ImageName的字符串
    AFBrowserItemTypeImageUrl,  // ImageURL的字符串或者URL
    AFBrowserItemTypeVideoUrl,  // 视频字符串或者URL
};

@interface AFImageBrowserItem : NSObject

/** 类型 */
@property (assign, nonatomic) AFBrowserItemType            type;

/** item */
@property (strong, nonatomic) id            image;


@property (strong, nonatomic) id            video;


@end


