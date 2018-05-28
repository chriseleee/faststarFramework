//
//  FileHandleTool.m
//  TestAPlayerIOS
//
//  Created by chrise on 2018/3/14.
//  Copyright © 2018年 xlxmp. All rights reserved.
//

#import "FileHandleTool.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <faststarVideo/faststarVideo.h>

//包大小
#define PackgeSize (1024*102)


@interface FileHandleTool ()

@property (assign, nonatomic) BOOL isfirst;


//是否需要压缩
@property (assign, nonatomic) BOOL needCompress;



@end

@implementation FileHandleTool


#pragma mark 创建读写句柄
-(void)creatReadAndWriteFileHandelName:(NSString*)fileName ofType:(NSString*)type
{

    self.path=  [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    
    //目标
    NSString * docpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    self.destFile =[docpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName,type]];
    
    NSString* toPath = [docpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_copy.%@",fileName,type]];
    [FaststarVideoTool makeVideoFasterFrom:self.path toPath:toPath];
    self.path = toPath;
    
    self.readHandle = [NSFileHandle fileHandleForReadingAtPath:_path];//读到内存

    //创建文件
    [[NSFileManager defaultManager] createFileAtPath:_destFile contents:nil attributes:nil];
    
    self.descHandle = [NSFileHandle fileHandleForWritingAtPath:_destFile];
    
    self.offset = 0;
    
    self.totalRet = [self.readHandle seekToEndOfFile];//返回文件大小
    
    NSLog(@"总大小：%llu",self.totalRet);

    self.isfirst = YES;
    
//    self.needCompress = [self getcompressionVideoInfoWithSourcePath:_path];
    

}


//yasuo
- (CGFloat)fileSize:(NSURL *)path
{
    return [[NSData dataWithContentsOfURL:path] length];
}


#pragma mark 读写数据
-(void)readAndWriteData{
//    self.needCompress = NO;
//    if (self.needCompress) {
//        [self compression];
//        return;
//    }
    
    
    NSData * _data = nil;

    if ((self.totalRet - self.offset)<= PackgeSize) {
        [self.readHandle seekToFileOffset:self.offset];
        _data = [self.readHandle readDataToEndOfFile];

        //偏移量设置为目标文件的最后，要不然会覆盖原来的内容
        [self.descHandle seekToEndOfFile];
        //写数据
        [self.descHandle writeData:_data];
        [self.descHandle closeFile];
        [self.readHandle closeFile];

        self.offset += _data.length;
        
        NSLog(@"写完了：写入了文件：%llu",self.offset);
        
        
    }else{
        //大于1M的文件多次读写
        [self.readHandle seekToFileOffset:self.offset];

        _data = [self.readHandle readDataOfLength:PackgeSize];

        //偏移量设置为目标文件的最后，要不然会覆盖原来的内容
        [self.descHandle seekToEndOfFile];
        //写数据
        [self.descHandle writeData:_data];

        self.offset += _data.length;

        [self performSelector:@selector(readAndWriteData) withObject:nil afterDelay:1.5];
        NSLog(@"写入了文件：%llu",self.offset);
    }

   
}



- (BOOL)getcompressionVideoInfoWithSourcePath:(NSString *)path{
    
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime   time = [asset duration];
    int seconds = ceil(time.value/time.timescale);
    
    NSInteger   fileSize = self.totalRet/(1024*1024);
    NSInteger badMax = fileSize*2;
    if (seconds>badMax) {//不用压缩
//        [self readAndWriteData];
        return NO;
    }else{
        
        return YES;
    }
    
}
//压缩
- (void)compression{
    
    // 创建AVAsset对象
    AVAsset* asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_path]];
    NSLog(@"asset:%@",asset);
    /*
     创建AVAssetExportSession对象
     压缩的质量
     AVAssetExportPresetLowQuality 最low的画质最好不要选择实在是看不清楚
     AVAssetExportPresetMediumQuality 使用到压缩的话都说用这个
     AVAssetExportPresetHighestQuality 最清晰的画质
     */
    AVAssetExportSession * session = [[AVAssetExportSession alloc]
                                      initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    
    //优化网络
    session.shouldOptimizeForNetworkUse = YES;
    //转换后的格式
    //拼接输出文件路径 为了防止同名 可以根据日期拼接名字 或者对名字进行MD5加密
    //目标
    NSString * docpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path =[docpath stringByAppendingPathComponent:@"apple1.mp4"];
    //判断文件是否存在，如果已经存在删除
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    //设置输出路径
    session.outputURL = [NSURL fileURLWithPath:path];
    //设置输出类型 这里可以更改输出的类型 具体可以看文档描述
    session.outputFileType = AVFileTypeMPEG4;
    
    __weak typeof(self) ws = self;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        __strong typeof(ws) strongSelf = ws;
        NSLog(@"%@",[NSThread currentThread]);
        //压缩完成
        if(session.status==AVAssetExportSessionStatusCompleted) {
            //在主线程中刷新UI界面，弹出控制器通知用户压缩完成
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"导出完成");
                NSURL* CompressURL = session.outputURL;
                strongSelf.totalRet = [strongSelf fileSize:CompressURL];
                NSLog(@"压缩完毕,压缩后大小 %llu ",strongSelf.totalRet);
                strongSelf.path = path;
                strongSelf.readHandle = [NSFileHandle fileHandleForReadingAtPath:path];//读到内存
                strongSelf.needCompress = NO;
                [strongSelf readAndWriteData];
            });
        }
    }];
}


@end
