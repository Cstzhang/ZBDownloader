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

- (void)dowbloader:(NSURL *)url
      downloadInfo:(DownloadInfoBlockType)downloadInfoBlock
          progress:(ProgressBlockType)progressBlock
           success:(SuccessBlockType)successBlock
            failed:(FailedBlockType)failedBlock;

- (void)pauseWithURL:(NSURL *)url;

- (void)cancelWithURL:(NSURL *)url;

- (void)resumeWithURL:(NSURL *)url;

- (void)pauseAll;

- (void)resumeAll;

- (void)cancelAll;


@end
