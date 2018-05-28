//
//  FaststarVideoTool.h
//  CGPlayingWithDownloading
//
//  Created by chriseleee on 2018/5/25.
//  Copyright © 2018年 chriseleee. All rights reserved.
//  mp4的moov置前

#import <Foundation/Foundation.h>

@interface FaststarVideoTool : NSObject

/*
 from: 视频原始目录
 toPath: 处理后视频位置
*/
+(void)makeVideoFasterFrom:(NSString*)from toPath:(NSString*)toPath;
/*
 path: 视频目录
 */
+(void)makeVideoFasterWithPath:(NSString*)path;

@end
