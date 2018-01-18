//
//  ZBDownloaderManager.m
//  ZBDownloader
//
//  Created by Mzhangzb on 18/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ZBDownloaderManager.h"
#import "NSString+ZB.h"
@interface ZBDownloaderManager ()<NSCopying,NSMutableCopying>

/** 下载器字典（每一个url一个下载器） */
@property (nonatomic,strong) NSMutableDictionary *downloadInfo;

@end


@implementation ZBDownloaderManager

static ZBDownloaderManager *_shareInstance;

+ (instancetype)shareInstance{
    if (_shareInstance == nil) {
        _shareInstance = [[self alloc]init];
    }
    return _shareInstance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

-(id)copyWithZone:(NSZone *)zone{
    
    return _shareInstance;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    
    return _shareInstance;
}



// key md5(url) value ZBDownloader
-(NSMutableDictionary *)downloadInfo{
    if (!_downloadInfo) {
        _downloadInfo = [[NSMutableDictionary alloc]init];
    }
    return _downloadInfo;
}

- (void)dowbloader:(NSURL *)url
      downloadInfo:(DownloadInfoBlockType)downloadInfoBlock
          progress:(ProgressBlockType)progressBlock
           success:(SuccessBlockType)successBlock
            failed:(FailedBlockType)failedBlock{
    //1 url
    NSString *urlMD5 = [url.absoluteString md5];
    //2 根据urlMD5 查找下载器
    ZBDownloader *downloader = self.downloadInfo[urlMD5];
    if (downloader == nil) {
        downloader = [[ZBDownloader alloc]init];
        self.downloadInfo[urlMD5] = downloader;
    }
    [downloader dowbloader:url downloadInfo:downloadInfoBlock progress:progressBlock success:^(NSString *cacheFilePath) {
        //拦截block
        [self.downloadInfo removeObjectForKey:urlMD5];
        successBlock(cacheFilePath);
    } failed:^{
        failedBlock();
    }];
    //下载完成后要移除下载器
    
    
}

- (void)pauseWithURL:(NSURL *)url{
    //1 url
    NSString *urlMD5 = [url.absoluteString md5];
    //2 根据urlMD5 查找下载器
    ZBDownloader *downloader = self.downloadInfo[urlMD5];
    
    [downloader pauseCurrentTask];
    
}

- (void)cancelWithURL:(NSURL *)url{
    //1 url
    NSString *urlMD5 = [url.absoluteString md5];
    //2 根据urlMD5 查找下载器
    ZBDownloader *downloader = self.downloadInfo[urlMD5];
    
    [downloader cancelCurrentTask];
}

- (void)resumeWithURL:(NSURL *)url{
    //1 url
    NSString *urlMD5 = [url.absoluteString md5];
    //2 根据urlMD5 查找下载器
    ZBDownloader *downloader = self.downloadInfo[urlMD5];
    
    [downloader resumeCurrentTask];
}


- (void)pauseAll{
    [self.downloadInfo.allValues performSelector:@selector(pauseCurrentTask) withObject:nil];
}

- (void)resumeAll{
    [self.downloadInfo.allValues performSelector:@selector(resumeCurrentTask) withObject:nil];
}

- (void)cancelAll{
    [self.downloadInfo.allValues performSelector:@selector(cancelCurrentTask) withObject:nil];
}


@end
