//
//  FileHandleTool.h
//  TestAPlayerIOS
//
//  Created by chrise on 2018/3/14.
//  Copyright © 2018年 xlxmp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHandleTool : NSObject

//读句柄
@property (strong, nonatomic) NSFileHandle * readHandle;
//写句柄
@property (strong, nonatomic) NSFileHandle *descHandle;
//句柄偏移量
@property (assign, nonatomic) unsigned long long offset;

//总大小
@property (assign, nonatomic) unsigned long long totalRet;
//url
@property (strong, nonatomic) NSString  *path;
//写入路径
@property (strong, nonatomic) NSString *destFile;

#pragma mark 创建读写句柄
-(void)creatReadAndWriteFileHandelName:(NSString*)fileName ofType:(NSString*)type;

#pragma mark 读写数据
-(void)readAndWriteData;

@end
