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

@property (nonatomic, strong) NSMutableDictionary <NSString *, ZBDownloader *>*downLoaderDic;
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


- (NSMutableDictionary *)downLoaderDic {
    if (!_downLoaderDic) {
        _downLoaderDic = [NSMutableDictionary dictionary];
    }
    return _downLoaderDic;
}

- (ZBDownloader *)getDownLoaderWithURL: (NSURL *)url {
    NSString *md5Name = [url.absoluteString MD5Str];
    ZBDownloader *downLoader = self.downLoaderDic[md5Name];
    return downLoader;
}

- (ZBDownloader *)downLoadWithURL: (NSURL *)url
                          fileInfo:(DownloadInfoBlockType)downLoadInfoBlcok
                           success:(SuccessBlockType)successBlock
                              fail:(FailedBlockType)failBlock
                          progress:(ProgressBlockType)progressBlock
                             state:(StateChangeBlockType)stateBlock {
    
    NSString *md5Name = [url.absoluteString MD5Str];
    ZBDownloader *downLoader = self.downLoaderDic[md5Name];
    if (downLoader == nil) {
        downLoader = [[ZBDownloader alloc] init];
        [self.downLoaderDic setValue:downLoader forKey:md5Name];
    }
    __weak typeof(self) weakSelf = self;
    [downLoader downLoadWithURL:url fileInfo:downLoadInfoBlcok progress:progressBlock state:stateBlock success:^(NSString *cachePath, long long totalFileSize) {
        if (successBlock) {
            successBlock(cachePath, totalFileSize);
        }
        [weakSelf.downLoaderDic removeObjectForKey:md5Name];
    } fail:failBlock];
    
    return downLoader;
}

- (void)pauseWithURL: (NSURL *)url {
    
    NSString *md5Name = [url.absoluteString MD5Str];
    ZBDownloader *downLoader = self.downLoaderDic[md5Name];
    [downLoader pause];
    
}


- (void)resumeWithURL: (NSURL *)url {
    NSString *md5Name = [url.absoluteString MD5Str];
    ZBDownloader *downLoader = self.downLoaderDic[md5Name];
    [downLoader resume];
}


- (void)cancelWithURL: (NSURL *)url {
    NSString *md5Name = [url.absoluteString MD5Str];
    ZBDownloader *downLoader = self.downLoaderDic[md5Name];
    [downLoader cancel];
}


- (void)cancelAndClearCacheWithURL: (NSURL *)url {
    NSString *md5Name = [url.absoluteString MD5Str];
    ZBDownloader *downLoader = self.downLoaderDic[md5Name];
    [downLoader cancelAndClearCache];
    
}

- (void)pauseAll {
    
    [[self.downLoaderDic allValues] makeObjectsPerformSelector:@selector(pause)];
    
}

- (void)resumeAll {
    
    [[self.downLoaderDic allValues] makeObjectsPerformSelector:@selector(resume)];
    
}





@end
