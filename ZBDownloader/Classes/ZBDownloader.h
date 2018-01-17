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

//一个下载器对应一个下载任务 一个 dowbloader->url
@interface ZBDownloader : NSObject

/**
 下载文件

 @param url 文件url
 */
- (void)dowbloader:(NSURL *)url;

/**
 暂停
 */
- (void)pauseCurrentTask;

/**
 取消任务
 */
- (void)cancelCurrentTask;

/**
 取消并清除缓存
 */
- (void)cancelTaskAndCleanCache;

/// 数据部分

/**
 下载状态
 */
@property (nonatomic, assign) ZBDownLoaderState state;




@end
