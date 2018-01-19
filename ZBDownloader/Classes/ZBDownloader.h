//
//  ZBDownloader.h
//  ZBDownloader
//
//  Created by Mzhangzb on 16/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//  downloader

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,ZBDownLoaderState){
    /** 下载暂停 */
    ZBDownLoaderStatePause,
    /** 正在下载 */
    ZBDownLoaderStateDowning,
    /** 已经下载 */
    ZBDownLoaderStateSuccess,
    /** 下载失败 */
    ZBDownLoaderStateFailed
};

typedef void(^DownloadInfoBlockType)(long long totalFileSize);
typedef void(^ProgressBlockType)(float progress);
typedef void(^SuccessBlockType)(NSString *cachePath,long long totalFileSize);
typedef void(^FailedBlockType)(NSString *errorMsg);
typedef void(^StateChangeBlockType)(ZBDownLoaderState state);

//一个下载器对应一个下载任务 一个 dowbloader->url
@interface ZBDownloader : NSObject

// 当前文件的下载状态
@property (nonatomic,assign,readonly) ZBDownLoaderState state;
// 当前文件的下载进度
@property (nonatomic,assign,readonly) float progress;

/** 文件下载信息的block */
@property (nonatomic,copy) DownloadInfoBlockType downLoadInfoBlcok;
/** 状态改变的block */
@property (nonatomic,copy) StateChangeBlockType stateChangeBlcok;
/** 进度改变的block */
@property (nonatomic,copy) ProgressBlockType progressBlock;
/** 下载成功的block */
@property (nonatomic,copy) SuccessBlockType successBlock;
/** 下载失败的block */
@property (nonatomic,copy) FailedBlockType failBlock;

// 根据url查找对应缓存, 如果不存在, 则返回nil
+ (NSString *)cachePathWithURL: (NSURL *)url;
+ (long long)tmpCacheSizeWithURL: (NSURL *)url;
+ (void)clearCacheWithURL: (NSURL *)url;

// 根据url地址, 进行下载
- (void)downLoadWithURL:(NSURL *)url ;
- (void)downLoadWithURL:(NSURL *)url
               fileInfo:(DownloadInfoBlockType)downLoadInfoBlcok
               progress:(ProgressBlockType)progressBlock
                  state:(StateChangeBlockType)stateBlock
                success:(SuccessBlockType)successBlock
                   fail:(FailedBlockType)failBlock;

// 继续
- (void)resume;

// 暂停
- (void)pause;

// 取消
- (void)cancel;

// 取消下载, 并删除缓存
- (void)cancelAndClearCache;





@end
