//
//  StringUtil.m
//  BaiduDownloader
//
//  Created by Yuri Boyka on 22/03/2018.
//  Copyright © 2018 Godlike Studio. All rights reserved.
//

#import "StringUtil.h"

@implementation NSString (RegexUtil)
//(\w)=(\d+)

- (NSString *)URLEncodedString
{
    NSString *encodedUrl = nil;
#if __MAC_OS_X_VERSION_MAX_ALLOWED < __MAC_10_11
    (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault, (CFStringRef)self, (CFStringRef) @"!$&'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
#else
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters =
        [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    encodedUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
#endif
    return encodedUrl;
}

- (NSArray *)matchWithRegex:(NSString *)regex
{
    NSRegularExpression *expression =
        [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];

    NSArray *matches = [expression matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    // match: 所有匹配到的字符,根据() 包含级
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches)
    {
        for (int i = 0; i < [match numberOfRanges]; i++)
        {
            //以正则中的(),划分成不同的匹配部分
            NSString *component = [self substringWithRange:[match rangeAtIndex:i]];
            [array addObject:component];
        }
    }
    return array;
}

- (NSString *)stringByReplacingRegex:(NSString *)regex replacement:(NSString *)replacement
{
    NSRegularExpression *regExp =
        [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *resultStr = self;
    resultStr = [regExp stringByReplacingMatchesInString:self
                                                 options:NSMatchingReportProgress
                                                   range:NSMakeRange(0, self.length)
                                            withTemplate:replacement];
    return resultStr;
}

- (NSArray *)stringArrayByRegex:(NSString *)regex;
{
    return [self matchWithRegex:regex];
}

- (NSString *)stringByRegex:(NSString *)regex { return [[self stringArrayByRegex:regex] firstObject]; }
- (NSString *)stringByKeyWord:(NSString *)keyword withSuffix:(NSString *)suffix
{
    NSString *regex = [self stringByRegex:[NSString stringWithFormat:@"%@.*?\%@", keyword, suffix]];
    if ([suffix isEqualToString:@"$"])
    {
        regex = [self stringByRegex:[NSString stringWithFormat:@"%@.*?%@", keyword, suffix]];
    }
    return [regex substringWithRange:NSMakeRange(keyword.length,
                                                 regex.length - (keyword.length +
                                                                 ([suffix isEqualToString:@"$"] ? 0 : suffix.length)))];
}

@end

#define u(x) [StringUtil encodeUnicodeWithUnichar:x]

@implementation StringUtil

+ (NSString *)encodeUnicodeWithString:(NSString *)string
{
    return [NSString stringWithCString:[string UTF8String] encoding:NSUnicodeStringEncoding];
}

+ (NSString *)encodeUnicodeWithUnichar:(unichar)ch
{
    return [StringUtil encodeUnicodeWithString:[NSString stringWithFormat:@"%d", ch]];
}

+ (NSString *)stringWithUnicodes:(NSArray *)unicodes { return [unicodes componentsJoinedByString:@""]; }
// unicode编码以\u开头
+ (NSString *)decodeUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

+ (NSString *)getUnicode:(NSString *)string
{
    if (string.length < 2)
    {
        unichar e = [string characterAtIndex:0];
        return 128 > e
                   ? string
                   : 2048 > e
                         ? [StringUtil stringWithUnicodes:@[ u(192 | e >> 6), u(128 | 63 & e) ]]
                         : [StringUtil
                               stringWithUnicodes:@[ u(224 | e >> 12 & 15), u(128 | e >> 6 & 63), u(128 | 63 & e) ]];
    }
    unichar e = 65536 + 1024 * ([string characterAtIndex:0] - 55296) + ([string characterAtIndex:1] - 56320);
    return [StringUtil
        stringWithUnicodes:@[ u(240 | e >> 18 & 7), u(128 | e >> 12 & 63), u(128 | e >> 6 & 63), u(128 | 63 & e) ]];
}

+ (NSString *)fileSizeWithBytes:(long long)bytes
{
    return [NSByteCountFormatter stringFromByteCount:bytes countStyle:NSByteCountFormatterCountStyleFile];
}

@end
