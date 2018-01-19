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
    NSURL * url = [NSURL URLWithString:@"https://codeload.github.com/Cstzhang/HXJTG/zip/master"];
//    NSURL * url2 = [NSURL URLWithString:@"https://codeload.github.com/Cstzhang/Leetcode/zip/Release"];
    [[ZBDownloaderManager shareInstance] downLoadWithURL:url fileInfo:^(long long totalFileSize) {
        NSLog(@" totalFileSize : %lld",totalFileSize);
    } success:^(NSString *cachePath, long long totalFileSize) {
        NSLog(@" cachePath : %@  totalFileSize %lld",cachePath,totalFileSize);
    } fail:^(NSString *errorMsg) {
        NSLog(@" errorMsg %@",errorMsg);
    } progress:^(float progress) {
        NSLog(@" progress %f",progress);
    } state:^(ZBDownLoaderState state) {
        NSLog(@" state %lu",(unsigned long)state);
    }];

    
    
}
- (IBAction)pause:(id)sender {
    NSURL * url = [NSURL URLWithString:@"https://codeload.github.com/Cstzhang/HXJTG/zip/master"];
    [[ZBDownloaderManager shareInstance] pauseWithURL:url];
}
- (IBAction)cancel:(id)sender {
    
    NSURL * url = [NSURL URLWithString:@"https://codeload.github.com/Cstzhang/HXJTG/zip/master"];
   [[ZBDownloaderManager shareInstance] cancelWithURL:url];
}

- (IBAction)cancelClean:(id)sender {
    
    NSURL * url = [NSURL URLWithString:@"https://codeload.github.com/Cstzhang/HXJTG/zip/master"];
    [[ZBDownloaderManager shareInstance] cancelAndClearCacheWithURL:url];
    
}




@end
