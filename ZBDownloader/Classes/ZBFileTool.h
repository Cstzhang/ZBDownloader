//
//  ZBFileTool.h
//  ZBDownloader
//
//  Created by Mzhangzb on 16/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBFileTool : NSObject

+ (BOOL)fileExists:(NSString *)filePath;

+ (long long)fileSize:(NSString *)filePath;

+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;

+ (void)removeFile:(NSString *)filePath;
@end
