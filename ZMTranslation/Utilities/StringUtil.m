//
//  StringUtil.m
//  BaiduDownloader
//
//  Created by Yuri Boyka on 22/03/2018.
//  Copyright © 2018 Godlike Studio. All rights reserved.
//

#import "StringUtil.h"

@implementation NSString (Split)

- (NSArray *)componentsSeparatedByLength:(int)length
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *paragraphs = [self componentsSeparatedByString:@"\n"];
    NSEnumerator *enumerator = [paragraphs objectEnumerator];
    NSString *paragraph;

    while ((paragraph = [enumerator nextObject]))
    {
        NSScanner *wordScanner = [NSScanner scannerWithString:paragraph];
        NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceCharacterSet];
        NSString *word = nil;
        NSString *separator = nil;
        NSMutableString *line = [NSMutableString stringWithCapacity:length];

        [wordScanner setCharactersToBeSkipped:[NSCharacterSet illegalCharacterSet]];

        while (![wordScanner isAtEnd])
        {
            [wordScanner scanUpToCharactersFromSet:whiteSpace intoString:&word];
            [wordScanner scanCharactersFromSet:whiteSpace intoString:&separator];

            if (([line length] + [word length] + [separator length]) <= length)
            {
                [line appendString:word];
                [line appendString:separator];
            }
            else
            {
                [array addObject:line];
                line = [NSMutableString stringWithString:word];
                [line appendString:separator];
            }
        }

        [array addObject:line];
    }

    return array;
}

@end

static inline int min(int a, int b, int c)
{
    int min = a;
    a = b < c ? b : c;
    return min < a ? min : a;
}

@implementation NSString (Similarity)

/*
 计算相似度，数值越大越相似，最大为1，表示相同,
 */
+ (float)sim:(NSString *)str1 str2:(NSString *)str2
{
    long ld = [NSString ld:str1 str2:str2];
    return 1.0 - MIN(1.0, (float)ld / (float)MAX(str1.length, str1.length));
}

/*
 *计算距离
 */
+ (long)ld:(NSString *)str1 str2:(NSString *)str2
{
    long n = str1.length;
    long m = str2.length;

    if (n == 0)
    {
        return m;
    }

    if (m == 0)
    {
        return n;
    }

    int d[n + 1][m + 1];  //矩阵
    int i;                //遍历str1的
    int j;                //遍历str2的
    unichar ch1;          // str1的
    unichar ch2;          // str2的
    int temp;             //记录相同字符,在某个矩阵位置值的增量,不是0就是1

    for (i = 0; i <= n; i++)
    {
        //初始化第一列
        d[i][0] = i;
    }

    for (j = 0; j <= m; j++)
    {
        //初始化第一行
        d[0][j] = j;
    }

    for (i = 1; i <= n; i++)
    {
        //遍历str1
        ch1 = [str1 characterAtIndex:(i - 1)];
        //去匹配str2
        for (j = 1; j <= m; j++)
        {
            ch2 = [str2 characterAtIndex:(j - 1)];  // str2.charAt(j-1);

            if (ch1 == ch2)
            {
                temp = 0;
            }
            else
            {
                temp = 1;
            }
            //左边+1,上边+1,左上角+temp取最小
            d[i][j] = min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + temp);
        }
    }

    return d[n][m];
}
@end

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
    return [self matchWithRegex:regex option:NSRegularExpressionCaseInsensitive];
}

- (NSArray *)matchWithRegex:(NSString *)regex option:(NSRegularExpressionOptions)option
{
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex options:option error:nil];

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
