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
/** strong属性注释 */
@property (nonatomic,strong) ZBDownloader *downloader;
@end

@implementation ViewController
- (ZBDownloader *)downloader{
    if (!_downloader) {
        _downloader = [[ZBDownloader alloc]init];
    }
    return _downloader;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSURL * url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"];
    [self.downloader dowbloader: url];
}

@end
