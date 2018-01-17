//
//  ViewController.m
//  ZBDownloader
//
//  Created by Mzhangzb on 16/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ViewController.h"
#import "ZBDownloader.h"
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
    NSLog(@"--- %luzd",(unsigned long)self.downloader.state);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self timer];
}



- (IBAction)download:(id)sender {
    NSURL * url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"];
    [self.downloader dowbloader: url];
    
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
