//
//  ViewController.m
//  TestAPlayerIOS
//
//  Created by xlxmp on 15/10/9.
//  Copyright (c) 2015年 xlxmp. All rights reserved.
//

#import "ViewController.h"

#import "FileHandleTool.h"
#import "AVPlayerChildController.h"

#import "SVProgressHUD.h"



//宽高的设置
#define WIDTH   [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (strong, nonatomic) FileHandleTool *fileHandle;

@end

@implementation ViewController
-(FileHandleTool *)fileHandle{
    if (!_fileHandle) {
        
        _fileHandle = [[FileHandleTool alloc]init];
        [_fileHandle creatReadAndWriteFileHandelName:@"test" ofType:@"mp4"];
    }
    return _fileHandle;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /**
     *  有关导航栏的设置
     */
    [self daohang];
    
    /**
     *   进行视频播放的跳转
     */
    UIButton *bofang = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH/2-100, HEIGHT-150, 200, 50)];
    [bofang setTitle:@"跳转播放" forState:UIControlStateNormal];
    [bofang setBackgroundColor:[UIColor brownColor]];
    [bofang addTarget:self action:@selector(bofang) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: bofang];

    [self.fileHandle readAndWriteData];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    
    
    
}


-(void)bofang
{

    AVPlayerChildController* vc = [AVPlayerChildController new];
    
    vc.urlString = self.fileHandle.destFile;
    vc.totalDataSize = self.fileHandle.totalRet;
    [self presentViewController:vc animated:YES completion:nil];

}



#pragma 导航栏的设置
-(void)daohang
{
    self.navigationController.navigationBar.barTintColor = [UIColor brownColor];
    
    self.title = @"视频播放";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:22]};
    self.view.backgroundColor = [UIColor grayColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end






















