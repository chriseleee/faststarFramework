//
//  AVPlayerChildController.m
//  AVPlayerViewController的使用
//
//  Created by chriseleee on 2018/3/21.
//  Copyright © 2018年 zhonghuatianchuang. All rights reserved.
//

#import "AVPlayerChildController.h"


#import "SVProgressHUD.h"


//宽高的设置
#define WIDTH   [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
@interface AVPlayerChildController ()
{
    AVAudioSession              *_session;
}

//读句柄
@property (strong, nonatomic) NSFileHandle * readHandle;

//视频总时长
@property (assign, nonatomic) CGFloat totalSeconds;

//视频缓冲
@property (assign, nonatomic) unsigned long long buff;
//当播放到多少的时候需要缓冲
@property (assign, nonatomic) NSInteger needBuff;
//下载完成
@property (assign, nonatomic) BOOL downloadOver;

//记录上一秒的位置
@property (assign, nonatomic) CGFloat needCheckLastTime;

@end

@implementation AVPlayerChildController

-(NSFileHandle *)readHandle{
    if (!_readHandle) {
        self.readHandle = [NSFileHandle fileHandleForReadingAtPath:self.urlString];//读到内存
    }
    return _readHandle;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    self.delegate = self;
    self.view.backgroundColor=[UIColor grayColor];
    
    //设置本地视频路径
    
    NSURL *url=[NSURL fileURLWithPath:self.urlString];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    CMTime   time = [asset duration];
    self.totalSeconds = time.value*1.0/time.timescale;
    
    self.buff = 2*self.totalSeconds/(self.totalDataSize/(1024*1024));
    
    
    unsigned long long currentSize = [self.readHandle seekToEndOfFile];//返回当前文件大小
    if (currentSize==self.totalDataSize) {
        
        self.needBuff = self.totalSeconds;
        self.downloadOver = YES;
    }else{
        //粗略计算当前能播放的时长
        self.needBuff = self.totalSeconds*currentSize/self.totalDataSize - self.buff;
    }
    
    self.needCheckLastTime = self.needBuff;
    AVPlayerItem *item=[AVPlayerItem playerItemWithAsset:asset];
    
    //设置流媒体视频路径
    //self.item=[AVPlayerItem playerItemWithURL:movieURL];
    
    //设置AVPlayer中的AVPlayerItem
    self.player=[AVPlayer playerWithPlayerItem:item];
    
    
    //监听status属性，注意监听的是AVPlayerItem
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //监听loadedTimeRanges属性
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //设置监听函数，监听视频播放进度的变化，每播放一秒，回调此函数
    __weak __typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
            
            [strongSelf calculationBuff];
        }

    }];
    
    
    _session = [AVAudioSession sharedInstance];
    [_session setCategory:AVAudioSessionCategoryPlayback error:nil];
    self.videoGravity = AVLayerVideoGravityResizeAspect;
//    self.allowsPictureInPicturePlayback = true;    //画中画，iPad可用
    self.showsPlaybackControls = true;
    self.view.translatesAutoresizingMaskIntoConstraints = true;


}


#pragma mark Play监听
//AVPlayerItem监听的回调函数
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        
        
    }else if ([keyPath isEqualToString:@"status"]){
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            NSLog(@"playerItem is ready");
            
            //如果视频准备好 就开始播放
            [self.player play];
            
        } else if(playerItem.status==AVPlayerStatusUnknown){
            NSLog(@"playerItem Unknown错误");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if (playerItem.status==AVPlayerStatusFailed){
            NSLog(@"playerItem 失败");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

//计算缓冲进度的函数
- (NSTimeInterval)availableDurationWithplayerItem:(AVPlayerItem *)playerItem
{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark 手动计算是否需要缓冲
-(void)calculationBuff{
    
    if (self.downloadOver) {
        return;
    }
    
    NSInteger current =  CMTimeGetSeconds(self.player.currentTime);
    
    if (self.needCheckLastTime<=current) {//需要处理数据
        unsigned long long currentSize = [self.readHandle seekToEndOfFile];//返回当前文件大小
        NSLog(@"currentSize %lld",currentSize);
        
        
        if (self.needBuff<current) {//进入以后就是暂停
            if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
                [SVProgressHUD showWithStatus:@"正在缓冲..."];
                [self.player pause];
                
            }
            [self performSelector:@selector(calculationBuff) withObject:nil afterDelay:3];
            if (currentSize==self.totalDataSize) {
                
                self.needBuff = self.totalSeconds;
                
            }else{
                //粗略计算当前能播放的时长
                self.needBuff = self.totalSeconds*currentSize/self.totalDataSize - self.buff;
            }
        }else{
            
            if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
                NSLog(@"切换前");
                [SVProgressHUD showWithStatus:@"正在缓冲..."];
                [self.player pause];
                [self performSelector:@selector(calculationBuff) withObject:nil afterDelay:3];
            }else{
                NSLog(@"切换");
                NSInteger current =  CMTimeGetSeconds(self.player.currentTime);
                
                [self removeObserverFromPlayerItem:self.player.currentItem];
                CMTime seekTime = CMTimeMake(current, 1);
                NSURL *url=[NSURL fileURLWithPath:self.urlString];
                
                AVAsset *asset = [AVAsset assetWithURL:url];
                
                AVPlayerItem *item=[AVPlayerItem playerItemWithAsset:asset];
                [self.player replaceCurrentItemWithPlayerItem:item];
                [self.player seekToTime:seekTime];
                //监听status属性，注意监听的是AVPlayerItem
                [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
                
                //监听loadedTimeRanges属性
                [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                
                NSLog(@"正在播放now %ld total %ld",(long)current,(long)self.needBuff);
                //                [self.player play];
                [SVProgressHUD dismiss];
                if (currentSize==self.totalDataSize) {
                    self.needBuff = self.totalSeconds;
                    self.downloadOver = YES;
                    [self.readHandle closeFile];
                }else{
                    //粗略计算当前能播放的时长
                    self.needBuff = self.totalSeconds*currentSize/self.totalDataSize - self.buff;
                }
                self.needCheckLastTime = self.needBuff;
            }
  
            
            
        }
    }else{
        if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
            [SVProgressHUD dismiss];
            [self.player play];
            
        }
    }
}


- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    //    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}



-(void)dealloc{
    NSLog(@"AVPlayerChildController Dealloc");
    if (!self.downloadOver) {
        
        [self.readHandle closeFile];
        
    }
    
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

