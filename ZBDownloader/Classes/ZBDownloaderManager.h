//
//  ZBDownloaderManager.h
//  ZBDownloader
//
//  Created by Mzhangzb on 18/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBDownloader.h"
@interface ZBDownloaderManager : NSObject

+ (instancetype)shareInstance;

- (ZBDownloader *)getDownLoaderWithURL: (NSURL *)url;

- (ZBDownloader *)downLoadWithURL: (NSURL *)url
                          fileInfo:(DownloadInfoBlockType)downLoadInfoBlcok
                           success:(SuccessBlockType)successBlock
                              fail:(FailedBlockType)failBlock
                          progress:(ProgressBlockType)progressBlock
                             state:(StateChangeBlockType)stateBlock;

- (void)pauseWithURL: (NSURL *)url;

- (void)resumeWithURL: (NSURL *)url;

- (void)cancelWithURL: (NSURL *)url;

- (void)cancelAndClearCacheWithURL: (NSURL *)url;

- (void)pauseAll;

- (void)resumeAll;



@end
