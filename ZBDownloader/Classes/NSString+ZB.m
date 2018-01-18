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

- (NSString *)md5{
    
    const char *data = self.UTF8String;
    //加密后的数组长度
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    // c语言字符串 -> md5 c字符串   加密内容，加密的长度，加密后的长度
    CC_MD5(data, (CC_LONG)strlen(data), md);
    
    //32 nsstring
    NSMutableString * result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    //遍历c语言字符串
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        //不足两位前面补0
        [result appendFormat:@"%02x",md[i]];
    }
    return result;
}

@end
