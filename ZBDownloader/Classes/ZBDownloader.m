//
//  ZBDownloader.m
//  ZBDownloader
//
//  Created by Mzhangzb on 16/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ZBDownloader.h"
#import "ZBFileTool.h"
#import "NSString+ZB.h"
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpPath   NSTemporaryDirectory()

#define kDownLoadURLOrStateChangeNotification @"downLoadURLOrStateChangeNotification"


@interface ZBDownloader () <NSURLSessionDataDelegate>{
    // 文件下载的总大小
    long long _totalFileSize;
    // 临时下载文件的大小
    long long _tmpFileSize;
}

/**
 下载Session会话
 */
@property (nonatomic,strong) NSURLSession *session;
/**
 当前下载任务
 */
@property (nonatomic,weak) NSURLSessionDataTask *task;

/**
 下载完成路径
 */
@property (nonatomic, copy)  NSString *cacheFilePath;

/**
 下载中路径
 */
@property (nonatomic, copy)  NSString *tmpFilePath;

/**
 文件输出流
 */
@property (nonatomic,strong) NSOutputStream *outputStream;

//文件URL
@property (nonatomic, weak) NSURL *url;

@end


@implementation ZBDownloader
@synthesize state = _state;

#pragma mark — 懒加载

- (NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]  delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

#pragma mark - 接口

+ (NSString *)cachePathWithURL: (NSURL *)url {
    
    NSString *cachePath = [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
    if ([ZBFileTool isExistsWithFile:cachePath]) {
        return cachePath;
    }
    return nil;
}

+ (long long)tmpCacheSizeWithURL: (NSURL *)url {
    
    NSString *tmpFileMD5 = [url.absoluteString MD5Str];
    NSString *tmpPath = [kTmpPath stringByAppendingPathComponent:tmpFileMD5];
    return  [ZBFileTool fileSizeWithPath:tmpPath];
}

+ (void)clearCacheWithURL: (NSURL *)url {
    NSString *cachePath = [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
    [ZBFileTool removeFileAtPath:cachePath];
}


// 注意, 临时缓存的位置(未下载完毕的位置): tmp/MD5(urlStr)
// 正式缓存的位置: cache/url.lastCompent

-(void)downLoadWithURL:(NSURL *)url
              fileInfo:(DownloadInfoBlockType)downLoadInfoBlcok
              progress:(ProgressBlockType)progressBlock
                 state:(StateChangeBlockType)stateBlock
               success:(SuccessBlockType)successBlock
                  fail:(FailedBlockType)failBlock{
    //赋值block
    self.downLoadInfoBlcok = downLoadInfoBlcok;
    self.progressBlock = progressBlock;
    self.successBlock = successBlock;
    self.failBlock = failBlock;
    self.stateChangeBlcok = stateBlock;
    //下载
    [self downLoadWithURL:url];
    
}


// 注意内部的容错处理, 如果被多次调用
// 需要根据当前的不同状态, 做不同的业务处理
- (void)downLoadWithURL: (NSURL *)url {
    
    self.url = url;
    // 文件下载完成后, 所在路径
    self.cacheFilePath = [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
    if ([ZBFileTool isExistsWithFile:self.cacheFilePath]) {
        
        if (self.downLoadInfoBlcok) {
            self.downLoadInfoBlcok([ZBFileTool fileSizeWithPath:self.cacheFilePath]);
        }
        
        if (self.successBlock) {
            self.successBlock(self.cacheFilePath, [ZBFileTool fileSizeWithPath:self.cacheFilePath]);
        }
        self.state = ZBDownLoaderStateSuccess;
        return;
    }
    
    // 如果正在下载, 则返回
    if (self.state == ZBDownLoaderStateDowning) {
        return;
    }
    //如果有任务在 且是暂停状态 就回复下载
    if (self.task && self.state == ZBDownLoaderStatePause) {
        [self resume];
        return;
    }
    
    // 文件还没下载完成, 所在路径
    NSString *tmpFileMD5 = [url.absoluteString MD5Str];
    self.tmpFilePath = [kTmpPath stringByAppendingPathComponent:tmpFileMD5];
    
    _tmpFileSize = [ZBFileTool fileSizeWithPath:self.tmpFilePath];

    // 使用 tmpFileSize, 作为偏移量进行下载请求
    [self downLoadWithURL:url fromBytesOffset:_tmpFileSize];
    
}

- (void)resume {
    // 此处坑: 如果连续点击了两次恢复, 则暂停需要点同样的次数
    // 解决方案; 通过状态进行判断
    if (self.task && self.state == ZBDownLoaderStatePause) {
        [self.task resume];
        self.state = ZBDownLoaderStateDowning;
    }
}

- (void)pause {
    // 此处坑: 如果连续点击了两次暂停, 则恢复需要点同样的次数
    // 解决方案; 通过状态进行判断
    if (self.state == ZBDownLoaderStateDowning) {
        [self.task suspend];
        self.state = ZBDownLoaderStatePause;
    }
}

// 取消请求
- (void)cancel {
    [self.session invalidateAndCancel];
    self.session = nil;
}
// 取消请求并清空各种缓存数据
- (void)cancelAndClearCache {
    [self cancel];
    
    // 清理缓存
    [ZBFileTool removeFileAtPath:self.tmpFilePath];
}

#pragma mark - 私有方法

- (void)setState:(ZBDownLoaderState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if (self.stateChangeBlcok) {
        self.stateChangeBlcok(state);
    }
    
    // 发送通知, 让外界监听状态改变
    if (self.url == nil) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadURLOrStateChangeNotification object:nil userInfo:@{@"state": @(self.state), @"url": self.url}];
}

- (void)setProgress:(float)progress {
    _progress = progress;
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
}

- (void)setUrl:(NSURL *)url {
    if ([_url isEqual:url] || url == nil) {
        return;
    }
    _url = url;
    // 发送通知, 让外界监听状态改变
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadURLOrStateChangeNotification object:nil userInfo:@{@"state": @(self.state), @"url": self.url}];
}

/**
 根据URL地址, 和偏移量进行下载
 
 @param url    url
 @param offset 偏移量
 */
- (void)downLoadWithURL:(NSURL *)url fromBytesOffset: (long long)offset {
    
    // 创建一个请求, 设置缓存策略, 和请求的Range字段
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    self.task = [self.session dataTaskWithRequest:request];
    
    [self.task resume];
}

#pragma mark - 代理

// 接收到响应之后做事情
- (void)URLSession:(NSURLSession *)session
             dataTask:(NSURLSessionDataTask *)dataTask
   didReceiveResponse:(NSURLResponse *)response
    completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSHTTPURLResponse *httpRes = (NSHTTPURLResponse *)response;
    // 获取文件总大小
    //    "Content-Length" = 21574062; 本次请求的总大小
    //    "Content-Range" = "bytes 0-21574061/21574062"; 本次请求的区间 开始字节-结束字节 / 总字节
     _totalFileSize = [httpRes.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpRes.allHeaderFields[@"Content-Range"]) {
        NSString *rangeStr = httpRes.allHeaderFields[@"Content-Range"] ;
        _totalFileSize = [[[rangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
        
    }
    //返回文件大小信息
    if (self.downLoadInfoBlcok) {
        self.downLoadInfoBlcok(_totalFileSize);
    }
    // 如果临时缓存已经足够了, 则, 直接移动文件到缓存路径下, 并取消本次请求
    if (_tmpFileSize == _totalFileSize) {
        [ZBFileTool moveFile:self.tmpFilePath toFile:self.cacheFilePath];
        completionHandler(NSURLSessionResponseCancel);
        // 给外界返回结果
        NSLog(@"临时文件已经存在: %@", self.cacheFilePath);
        if (self.successBlock) {
            self.successBlock(self.cacheFilePath, _totalFileSize);
        }
        return;
    }
    //无法获取总文件大小
    if (0 == _totalFileSize) {
        // 删除缓存
        [ZBFileTool removeFileAtPath:self.tmpFilePath];
        // 取消本次请求
        completionHandler(NSURLSessionResponseCancel);
        // 给外界返回结果
        NSLog(@"文件总大小未知,无法下载: %@", httpRes);
        if (self.failBlock) {
            self.failBlock(@"文件总大小未知,无法下载");
        }
        return;
    }
    //缓存文件有问题
    if (_tmpFileSize > _totalFileSize) {
        NSLog(@"缓存有问题, 删除缓存, 重新下载");
        // 删除缓存
        [ZBFileTool removeFileAtPath:self.tmpFilePath];
        // 取消本次请求
        completionHandler(NSURLSessionResponseCancel);
        // 重新开始新的请求
        [self downLoadWithURL:dataTask.originalRequest.URL];
        return;
    }
    //有缓存文件 但是不支持断点续传
    if (_tmpFileSize > 0 && !httpRes.allHeaderFields[@"Content-Range"]){
        NSLog(@"文件不支持断点续传,重新下载");
        // 删除缓存
        [ZBFileTool removeFileAtPath:self.tmpFilePath];
        // 取消本次请求
        completionHandler(NSURLSessionResponseCancel);
        // 重新开始新的请求
        [self downLoadWithURL:dataTask.originalRequest.URL];
        return;
        
    }
    // 开始创建文件输出流, 开始接收数据
    NSLog(@"应该直接接收数据");
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath append:YES];
    [self.outputStream open];
    
    self.state = ZBDownLoaderStateDowning;
    
    // allow: 代表, 继续接收数据
    // cancel: 代表, 取消本次请求
    completionHandler(NSURLSessionResponseAllow);
    
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    _tmpFileSize += data.length;
    self.progress = 1.0 * _tmpFileSize / _totalFileSize;
    // 接收数据, 会调用多次
    [self.outputStream write:data.bytes maxLength:data.length];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        NSLog(@"下载出错--%@", error);
        self.state = ZBDownLoaderStateFailed;
        if (self.failBlock) {
            self.failBlock(error.localizedDescription);
        }
    }else {
        NSLog(@"下载成功");
        [ZBFileTool moveFile:self.tmpFilePath toFile:self.cacheFilePath];
        self.state = ZBDownLoaderStateSuccess;
        if (self.successBlock) {
            self.successBlock(self.cacheFilePath, _totalFileSize);
        }
        
    }
    
    // 释放资源
    [self.outputStream close];
     self.outputStream = nil;
    
}



@end
