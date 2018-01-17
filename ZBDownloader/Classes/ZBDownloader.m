//
//  ZBDownloader.m
//  ZBDownloader
//
//  Created by Mzhangzb on 16/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ZBDownloader.h"
#import "ZBFileTool.h"
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpPath   NSTemporaryDirectory()



@interface ZBDownloader () <NSURLSessionDataDelegate>{
    long long _tmpSize;
    long long _totalSize;
}

/**
 下载Session
 */
@property (nonatomic,strong) NSURLSession *session;

/**
 下载完成路径
 */
@property (nonatomic, copy)  NSString *downLoadedPath;

/**
 下载中路径
 */
@property (nonatomic, copy)  NSString *downLoadingPath;

/**
 输出流
 */
@property (nonatomic,strong) NSOutputStream *outputStream;

/**
 下载任务
 */
@property (nonatomic,weak) NSURLSessionDataTask *dataTask;

@end

@implementation ZBDownloader

- (void)dowbloader:(NSURL *)url{
    //内部实现
      //1,从头开始下载
      //2,如果任务存在，继续下载
    //当前任务存在
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
       //如果状态是暂停，则继续
        [self resumeCurrentTask];
        return;
    }
    
    
    NSString *fileName = url.lastPathComponent;
    self.downLoadedPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downLoadingPath = [kTmpPath stringByAppendingPathComponent:fileName];
    // 1.  判断url对应的资源是否已经下载完毕
    if ([ZBFileTool fileExists:self.downLoadedPath]) {
        //TODO: -告诉外界已经下载完成
        NSLog(@"已经存在文件,无需下载:%@",self.downLoadedPath);
        self.state = ZBDownLoaderStateSuccess;
        return;
    }
    // 1.2  检测临时文件temp是否存在
    if (![ZBFileTool fileExists:self.downLoadingPath]) {
        [self downLoadWithURL:url offset:0];
        return;
    }
    //本地文件大小获取，
    _tmpSize = [ZBFileTool fileSize:self.downLoadingPath];
    [self downLoadWithURL:url offset:_tmpSize];
    
}

#pragma mark — 协议方法
// 第一次接受到响应的时候调用（有响应头信息，没有具体的内容信息）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString * contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        _totalSize =  [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    //比对本地大小和总大小
    if (_totalSize == _tmpSize) {
        // 1.移动文件到下载完成文件夹
        NSLog(@"移动文件到下载完成文件夹:%@",self.downLoadedPath);
        [ZBFileTool moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        // 2.取消本次下载
        completionHandler(NSURLSessionResponseCancel);
        
        self.state = ZBDownLoaderStateSuccess;
        return;
    }
    if (_totalSize < _tmpSize) {
        // 1.删除临时缓存
        NSLog(@"删除临时缓存: %@",self.downLoadingPath);
        [ZBFileTool removeFile:self.downLoadingPath];
        // 2.取消本次请求
        completionHandler(NSURLSessionResponseCancel);
        // 3.从0开始下载
        NSLog(@"从0开始下载");
        [self dowbloader:response.URL];
        return;
    }
    self.state = ZBDownLoaderStateDowning;
    //文件输出流
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLoadingPath append:YES];
    [self.outputStream open];
    //继续接收数据
    completionHandler(NSURLSessionResponseAllow);
}

// 当客户端确定继续接收数据的时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.outputStream write:data.bytes maxLength:data.length];
}

// 请求完成时调用
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error == nil) {
        NSLog(@"请求完成文件夹:%@",self.downLoadedPath);
        //不一定成功,数据请求完毕,判断本地缓存是否等于文件总大小,如果等于还需验证文件是否完整（file md5）
        //TODO: - 验证文件是否完整
        [ZBFileTool moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        self.state = ZBDownLoaderStateSuccess;
    }else{
        NSLog(@"下载异常： %@",error);
        //取消？ 网络断开
        if (error.code == -999) {//取消
            self.state = ZBDownLoaderStatePause;
        }else{
            self.state = ZBDownLoaderStateFailed;
        }
    }
    [self.outputStream close];
}

#pragma mark — 私有方法

/**
 根据offset起始字节请求数据下载

 @param url url
 @param offset 起始字节
 */
- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    // session 分配的Task任务 默认：挂起状态
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeCurrentTask];
}

/**
 暂停 (调用了几次继续,就需要调用几次暂停才可以实现暂停)
 */
- (void)pauseCurrentTask{
    if (self.state == ZBDownLoaderStateDowning) {
        self.state = ZBDownLoaderStatePause;
        [self.dataTask suspend];
    }
}

/**
 取消任务
 */
- (void)cancelCurrentTask{
    self.state = ZBDownLoaderStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
   
}

/**
 取消并清除缓存
 */
- (void)cancelTaskAndCleanCache{
    [self cancelCurrentTask];
    [ZBFileTool removeFile:_downLoadingPath];
    //
}

/**
 恢复继续下载状态 (调用了几次暂停,就需要调用几次继续才可以继续)
 */
- (void)resumeCurrentTask{
    if (self.dataTask && self.state == ZBDownLoaderStatePause ) {
        [self.dataTask resume];
        self.state = ZBDownLoaderStateDowning;
    }
}

#pragma mark — 懒加载

- (NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

#pragma mark — 数据/事件传递

-(void)setState:(ZBDownLoaderState)state{
    if (_state == state) {
        return;
    }
    _state = state;
    //推模式：block 代理 通知
    //拉模式：外界主动获取属性

}


@end
