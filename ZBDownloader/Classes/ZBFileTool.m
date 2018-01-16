//
//  ZBFileTool.m
//  ZBDownloader
//
//  Created by Mzhangzb on 16/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ZBFileTool.h"

@implementation ZBFileTool

+ (BOOL)fileExists:(NSString *)filePath{
    if (filePath.length == 0) {
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (long long)fileSize:(NSString *)filePath{
    if (![self fileExists:filePath]) {
        return 0;
    }
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return [fileInfo[NSFileSize] longLongValue];
}

+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath{
    if (![self fileExists:fromPath]) {
        return ;
    }
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

+ (void)removeFile:(NSString *)filePath{
    if (![self fileExists:filePath]) {
        return ;
    }
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}
@end
