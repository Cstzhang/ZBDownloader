//
//  ZBFileTool.h
//  ZBDownloader
//
//  Created by Mzhangzb on 16/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBFileTool : NSObject
+ (BOOL)isExistsWithFile: (NSString *)filePath;

+ (long long)fileSizeWithPath: (NSString *)filePath;

+ (void)moveFile: (NSString *)fromPath toFile: (NSString *)toPath;

+ (void)removeFileAtPath: (NSString *)filePath;
@end
