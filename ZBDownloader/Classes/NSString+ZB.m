//
//  NSString+ZB.m
//  ZBDownloader
//
//  Created by Mzhangzb on 18/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "NSString+ZB.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ZB)

- (NSString *)MD5Str{
    
    // 1. 转换成C语言字符串
    const char *cStr = [self UTF8String];
    
    // 2. 创建MD5 C 字符串存储数组
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    // 3. 使用CC_MD5函数进行转换
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    // 4. 把 MD5的C字符串, 转换成为 NSString
    NSMutableString *strM = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [strM appendFormat:@"%02x", digest[i]];
    }
    
    return [strM copy];
}

@end
