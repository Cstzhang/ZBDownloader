//
//  ViewController.m
//  ZBDownloader
//
//  Created by Mzhangzb on 16/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ViewController.h"
#import "ZBDownloader.h"
#import "ZBDownloaderManager.h"
@interface ViewController ()
/** 下载器 */
@property (nonatomic,strong) ZBDownloader *downloader;

/** 计时器 */
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ViewController

- (NSTimer *)timer{
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateState) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}
- (ZBDownloader *)downloader{
    if (!_downloader) {
        _downloader = [[ZBDownloader alloc]init];
    }
    return _downloader;
}

-(void)updateState{
//    NSLog(@"--- %luzd",(unsigned long)self.downloader.state);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self timer];
}



- (IBAction)download:(id)sender { 
    NSURL * url = [NSURL URLWithString:@"https://codeload.github.com/Cstzhang/Leetcode/zip/master"];
//    NSURL * url2 = [NSURL URLWithString:@"https://codeload.github.com/Cstzhang/Leetcode/zip/Release"];
    [[ZBDownloaderManager shareInstance] dowbloader:url downloadInfo:^(long long totalSize) {
       NSLog(@"下载信息 %lld",totalSize);
    } progress:^(float progress) {
         NSLog(@"下载进度 %f",progress);
    } success:^(NSString *cacheFilePath) {
          NSLog(@"下载成功 %@",cacheFilePath);
    } failed:^{
          NSLog(@"下载失败");
    }];
    
//    [[ZBDownloaderManager shareInstance] dowbloader:url2 downloadInfo:^(long long totalSize) {
//        NSLog(@"下载信息 %lld",totalSize);
//    } progress:^(float progress) {
//        NSLog(@"下载进度 %f",progress);
//    } success:^(NSString *cacheFilePath) {
//        NSLog(@"下载成功 %@",cacheFilePath);
//    } failed:^{
//        NSLog(@"下载失败");
//    }];
    
    
    
}
- (IBAction)pause:(id)sender {
    [self.downloader pauseCurrentTask];
}
- (IBAction)cancel:(id)sender {
    [self.downloader cancelCurrentTask];
}

- (IBAction)cancelClean:(id)sender {
    [self.downloader cancelTaskAndCleanCache];
    
}




@end
