//
//  StringUtil.h
//  BaiduDownloader
//
//  Created by Yuri Boyka on 22/03/2018.
//  Copyright © 2018 Godlike Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Split)

- (NSArray *)componentsSeparatedByLength:(int)length;

@end

@interface NSString (Similarity)

+ (float)sim:(NSString *)str1 str2:(NSString *)str2;

@end

@interface NSString (RegexUtil)

- (NSString *)URLEncodedString;

/**
 正则匹配安徽符合要求的字符串 数组

 @param regex 正则表达式
 @param option 正则选项
 @return 符合要求的字符串 数组 (按(),分级,正常0)
 */
- (NSArray *)matchWithRegex:(NSString *)regex option:(NSRegularExpressionOptions)option;

/**
 *  正则匹配返回符合要求的字符串 数组
 *
 *  @param regex  正则表达式
 *
 *  @return 符合要求的字符串 数组 (按(),分级,正常0)
 */
- (NSArray *)matchWithRegex:(NSString *)regex;

/**
 根据正则表达式替换字符串

 @param regex 正则表达式
 @param replacement 替换的字符串
 @return 返回替换后的结果
 */
- (NSString *)stringByReplacingRegex:(NSString *)regex replacement:(NSString *)replacement;

/**
 返回正则匹配的所有结果
 */
- (NSArray *)stringArrayByRegex:(NSString *)regex;

/**
 正则匹配的字符串
 */
- (NSString *)stringByRegex:(NSString *)regex;

/**
 根据关键字和后缀返回匹配到的结果
 */
- (NSString *)stringByKeyWord:(NSString *)keyword withSuffix:(NSString *)suffix;

@end

@interface StringUtil : NSObject

+ (NSString *)fileSizeWithBytes:(long long)bytes;

@end
