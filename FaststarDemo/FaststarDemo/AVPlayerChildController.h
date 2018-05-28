//
//  AVPlayerChildController.h
//  AVPlayerViewController的使用
//
//  Created by chriseleee on 2018/3/21.
//  Copyright © 2018年 zhonghuatianchuang. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface AVPlayerChildController : AVPlayerViewController

//播放路径
@property (strong, nonatomic) NSString *urlString;

//总大小
@property (assign, nonatomic) unsigned long long totalDataSize;

@end
