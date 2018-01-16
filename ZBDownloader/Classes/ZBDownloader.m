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
@property (nonatomic,strong) NSURLSession *session;

@property (nonatomic, copy)  NSString *downLoadedPath;

@property (nonatomic, copy)  NSString *downLoadingPath;

@property (nonatomic,strong) NSOutputStream *outputStream;

@end


@implementation ZBDownloader



- (void)dowbloader:(NSURL *)url{
    // 0. 文件存放
      // 下载中  temp + 文件名
      // MD5 + URL 防止重复资源
      // 下载完成 cache + 名称
    NSString *fileName = url.lastPathComponent;
    self.downLoadedPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downLoadingPath = [kTmpPath stringByAppendingPathComponent:fileName];
    // 1.  判断url对应的资源是否已经下载完毕
    // 1.1 下载完毕，return（本地文件路径 文件大小）
    if ([ZBFileTool fileExists:self.downLoadedPath]) {
        //TODO: -告诉外界已经下载完成
        NSLog(@"已经存在文件,无需下载:%@",self.downLoadedPath);
        return;
    }
    // 1.2  检测临时文件temp是否存在
       //本地无缓存：从0字节开始请求资源 return
    if (![ZBFileTool fileExists:self.downLoadingPath]) {
        //从0开始下载
        [self downLoadWithURL:url offset:0];
        return;
    }
    // 1.3 检测到临时文件temp是存在， HTTP rang:开始字节 （比较下载文件的大小与文件的总大小）
       //本地大小 == 总大小 移动已经下载完成的文件 到 cache
       //本地大小 < 总大小 从当前本地大小开始网络请求资源继续下载
       //本地大小 > 总大小 删除本地文件，从0开始下载
    //本地文件大小获取，
    _tmpSize = [ZBFileTool fileSize:self.downLoadingPath];
    [self downLoadWithURL:url offset:_tmpSize];
    //文件总大小(网络请求获取 同步请求)
}

#pragma mark — 协议方法
// 第一次接受到响应的时候调用（有响应头信息，没有具体的内容信息）
// 通过这个方法，系统提供的代码块可以控制是否继续请求
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    //NSLog(@"%@",response);
    // Content-Length 请求的大小 != 资源的大小
    // 取资源的总大小
    // 1. 从Content-Length获取
    // 2. 如果Content-Range有，应该从Content-Range取
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
        return;
    }
    if (_totalSize < _tmpSize) {
        // 1.删除临时缓存
        NSLog(@"删除临时缓存: %@",self.downLoadingPath);
        [ZBFileTool removeFile:self.downLoadingPath];
        // 2.从0开始下载
        NSLog(@"从0开始下载");
        [self dowbloader:response.URL];
        // 3.取消本次请求
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    //文件输出流
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLoadingPath append:YES];
    [self.outputStream open];
    //继续接收数据
    completionHandler(NSURLSessionResponseAllow);
}

// 当客户端确定继续接收数据的时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSLog(@"接收后续数据");
    [self.outputStream write:data.bytes maxLength:data.length];
}

// 请求完成时调用
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error == nil) {
        NSLog(@"请求完成文件夹:%@",self.downLoadedPath);
        //不一定成功,数据请求完毕,判断本地缓存是否等于文件总大小,如果等于还需验证文件是否完整（file md5）
        //TODO: -
    }else{
        NSLog(@"下载异常");
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
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    [dataTask resume];
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




@end
