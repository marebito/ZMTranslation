//
//  HttpUtil.h
//  BaiduDownloader
//
//  Created by Yuri Boyka on 2018/3/19.
//  Copyright © 2018年 Godlike Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ONOXMLElement;

#define REQUEST_LOG 0

#define __UD__ [NSUserDefaults standardUserDefaults]
#define __UDGET__(o) [__UD__ objectForKey:o]
#define __UDSET__(k, v) [__UD__ setObject:v forKey:k]
#define __UDSYNC__ [__UD__ synchronize]
#define __UDREMOVE__(k) [[NSUserDefaults standardUserDefaults] removeObjectForKey:k]

#define __HEADV__(o, k) ((NSHTTPURLResponse *)o).allHeaderFields[k]
#define __SETCOOKIE__(o) ((NSHTTPURLResponse *)o).allHeaderFields[@"Set-Cookie"]

#define __MREGEX__(string, regex) [string matchWithRegex:regex];
#define __VREGEX__(string, keyword, suffix) [string stringByKeyWord:keyword withSuffix:suffix]

#define __RD__(o) [[NSString alloc] initWithData:o encoding:NSUTF8StringEncoding]
#define __JSONDIC__(o) [NSJSONSerialization JSONObjectWithData:o options:NSJSONReadingMutableContainers error:nil];

@interface HttpUtil : NSObject

+ (NSMutableDictionary *)commonHeader;

+ (NSMutableDictionary *)headerWithContentLength:(NSInteger)contentLen
                                          cookie:(NSString *)cookie
                                            host:(NSString *)host
                                          origin:(NSString *)origin
                                         Referer:(NSString *)referer;

+ (void)clearAllCookies;

+ (NSString *)currentTimestamp;

+ (NSString *)currentMilliTimestamp;

+ (NSString *)currentTimestampDelay:(long long)delay;

+ (NSString *)currentMilliTimestampDelay:(long long)delay;

+ (NSString *)URLParamsString:(NSDictionary *)dic;

+ (NSString *)URLEncodedString:(NSString *)str;

+ (NSString *)URLDecodedString:(NSString *)str;

+ (void)request:(NSString *)url
         method:(NSString *)mothod
        headers:(NSDictionary *)headers
         params:(NSDictionary *)params
     completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion;

/**
 根据URL获取文件信息

 @param url 文件链接
 @param fileInfo 文件信息
 */
+ (void)getFileInfoWithURL:(NSString *)url fileInfo:(void (^)(NSDictionary *dic))fileInfo;

+ (void)htmlForURL:(NSString *)url
             xPath:(NSString *)xPath
 completionHandler:(void (^)(ONOXMLElement *element, NSUInteger idx, BOOL *_Nonnull stop))complete;

@end
