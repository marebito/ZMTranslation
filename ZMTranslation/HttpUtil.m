//
//  HttpUtil.m
//  BaiduDownloader
//
//  Created by Yuri Boyka on 2018/3/19.
//  Copyright © 2018年 Godlike Studio. All rights reserved.
//

#import "HttpUtil.h"
#import "AFNetworking.h"
#import "ONO.h"
#import "StringUtil.h"

@implementation HttpUtil

+ (NSMutableDictionary *)commonHeader
{
    return [NSMutableDictionary dictionaryWithDictionary:@{
        @"Accept" : @"application/json, text/javascript, */*; q=0.01",
        @"Accept-Encoding" : @"gzip, deflate",
        @"Accept-Language" : @"zh-CN,zh;q=0.9",
        @"Connection" : @"keep-alive",
        @"Content-Type" : @"application/x-www-form-urlencoded; charset=UTF-8",
        @"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) "
                        @"Chrome/68.0.3440.106 Safari/537.36",
        @"X-Requested-With" : @"XMLHttpRequest"
    }];
}

+ (NSMutableDictionary *)headerWithContentLength:(NSInteger)contentLen
                                          cookie:(NSString *)cookie
                                            host:(NSString *)host
                                          origin:(NSString *)origin
                                         Referer:(NSString *)referer
{
    NSMutableDictionary *dic = [HttpUtil commonHeader];
    [dic setObject:[NSString stringWithFormat:@"%ld", (long)contentLen] forKey:@"Content-Length"];
    [dic setObject:cookie forKey:@"Cookie"];
    [dic setObject:host forKey:@"Host"];
    if (origin)
    {
        [dic setObject:origin forKey:@"Origin"];
    }
    if (referer)
    {
        [dic setObject:referer forKey:@"referer"];
    }
    else
    {
        [dic setObject:origin forKey:@"referer"];
    }
    return dic;
}

/*
 iOS中，应用退出，会话结束的时候，Cookies是默认被丢弃的,而浏览器默认是保存的。
 */
+ (void)cacheCookies:(NSString *)url
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:url]];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *_Nonnull cookie, NSUInteger idx, BOOL *_Nonnull stop) {
        NSMutableDictionary *properties = [[cookie properties] mutableCopy];
        //将cookie过期时间设置为一年后
        NSDate *expiresDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 30 * 12];
        properties[NSHTTPCookieExpires] = expiresDate;
        //下面一行是关键,删除Cookies的discard字段，应用退出，会话结束的时候继续保留Cookies
        [properties removeObjectForKey:NSHTTPCookieDiscard];
        //重新设置改动后的Cookies
        [cookieStorage setCookie:[NSHTTPCookie cookieWithProperties:properties]];
    }];
}

+ (void)clearResponseCacheWithURL:(NSString *)url
{
    [[NSURLCache sharedURLCache]
        removeCachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

+ (void)clearResponseCache { [[NSURLCache sharedURLCache] removeAllCachedResponses]; }
+ (void)clearAllCookies
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    [self clearResponseCache];
}

+ (void)clearCookie:(NSString *)url name:(NSArray *)cookieNames
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:url]];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        if (cookieNames.count > 0)
        {
            [cookieNames enumerateObjectsUsingBlock:^(NSString *cookieName, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([cookieName isEqualToString:cookie.name])
                {
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                }
            }];
        }
        else
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }];
}

+ (NSString *)currentTimestamp
{
    return [NSString stringWithFormat:@"%llu", (unsigned long long)[[NSDate date] timeIntervalSince1970]];
}

+ (NSString *)currentTimestampDelay:(long long)delay
{
    return [NSString stringWithFormat:@"%llu", (unsigned long long)([[NSDate date] timeIntervalSince1970] + delay)];
}

+ (NSString *)currentMilliTimestamp
{
    return [NSString stringWithFormat:@"%llu", (unsigned long long)([[NSDate date] timeIntervalSince1970] * 1000)];
}

+ (NSString *)currentMilliTimestampDelay:(long long)delay
{
    return [NSString
        stringWithFormat:@"%llu", (unsigned long long)(([[NSDate date] timeIntervalSince1970] + delay) * 1000)];
}

+ (NSString *)URLParamsString:(NSDictionary *)dic
{
    NSMutableString *string = [[NSMutableString alloc] init];
    for (NSString *key in dic)
    {
        [string appendFormat:@"%@=%@&", key, dic[key]];
    }
    return [string substringToIndex:string.length - 1];
}

+ (NSString *)URLEncodedString:(NSString *)str
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault, (CFStringRef)str, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    return encodedString;
}

+ (NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
        NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

+ (void)request:(NSString *)url
         method:(NSString *)method
        headers:(NSDictionary *)headers
         params:(NSDictionary *)params
     completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion
{
    [HttpUtil clearAllCookies];
    NSLog(@"\n[请求链接]:%@\n[请求方式]:%@\n[请求头]:\n%@\n[参数]:\n%@\n", url, method, headers, params);
    NSMutableURLRequest *request =
        [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:url parameters:params error:nil];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    for (NSString *key in headers)
    {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest *_Nullable(
                 NSURLSession *_Nonnull session, NSURLSessionTask *_Nonnull task, NSURLResponse *_Nonnull response,
                 NSURLRequest *_Nonnull request) {
        NSLog(@"\n[响应状态码] : \n%ld\n\n[响应头] : \n%@\n\n", (long)((NSHTTPURLResponse *)response).statusCode,
              ((NSHTTPURLResponse *)response).allHeaderFields);
        if ((long)((NSHTTPURLResponse *)response).statusCode == kCFErrorHTTPConnectionLost &&
            ((NSHTTPURLResponse *)response).allHeaderFields[@"Location"])
        {
            NSString *location = __HEADV__(response, @"Location");
            NSString *baiduid = __VREGEX__(__SETCOOKIE__(response), @"BAIDUID=", @";");
            NSLog(@"\n[重定向链接]:%@\n[BAIDUID]:%@\n[请求方式]:%@\n[请求头]:\n%@\n[参数]:\n%@\n", location, baiduid,
                  method, headers, params);
            if (location.length > 0)
            {
                __UDSET__(@"Location", location);
            }
            if (baiduid.length > 0)
            {
                __UDSET__(@"BAIDUID", baiduid);
            }
            __UDSYNC__;
            return [NSURLRequest requestWithURL:[NSURL URLWithString:__HEADV__(response, @"Location")]];
        }
        return request;
    }];

    NSURLSessionTask *task = [manager
        dataTaskWithRequest:request
             uploadProgress:nil
           downloadProgress:nil
          completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
              id responseObjectCopy = [responseObject copy];
              NSURLResponse *responseCopy = [response copy];
              NSString *responseJSON = [[NSString alloc] initWithData:responseObjectCopy encoding:NSUTF8StringEncoding];
              NSLog(@"\n[响应状态码] : \n%ld\n\n[响应头] : \n%@\n\n[返回数据] : \n%@\n\n[错误] : \n%@\n",
                    (long)((NSHTTPURLResponse *)responseCopy).statusCode,
                    ((NSHTTPURLResponse *)responseCopy).allHeaderFields, responseJSON,
                    error ? [error debugDescription] : @"无");
              if (completion)
              {
                  completion(response, responseObject, error);
              }
          }];
    [task resume];
}

+ (void)getFileInfoWithURL:(NSString *)url fileInfo:(void (^)(NSDictionary *dic))fileInfo
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"HEAD";
    NSURLSession *session =
        [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
              NSString *mime = response.MIMEType;
              long long fileSize = response.expectedContentLength;
              NSString *encoding = response.textEncodingName;
              NSString *fileName = response.suggestedFilename;
              const char *byte = NULL;
              byte = [fileName cStringUsingEncoding:NSISOLatin1StringEncoding];
              //        NSStringEncoding enc =
              //        CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
              fileName =
                  [[NSString alloc] initWithCString:byte
                                           encoding:NSUTF8StringEncoding];  //如是utf，此处应改为NSUTF8StringEncoding
              if (fileInfo)
              {
                  fileInfo(@{
                      @"MIME" : mime,
                      @"size" : @(fileSize),
                      @"encoding" : encoding ? encoding : @"utf-8",
                      @"fileName" : fileName
                  });
              }
          }];
    [task resume];
}

+ (void)htmlForURL:(NSString *)url
             xPath:(NSString *)xPath
 completionHandler:(void (^)(ONOXMLElement *element, NSUInteger idx, BOOL *_Nonnull stop))complete
{
    [HttpUtil request:url
               method:@"GET"
              headers:nil
               params:nil
           completion:^(NSURLResponse *response, id responseObject, NSError *error) {
               NSError *onoError;
               ONOXMLDocument *doc = [ONOXMLDocument HTMLDocumentWithData:responseObject error:&onoError];
               ONOXMLElement *parentElement = [doc firstChildWithXPath:xPath];
               [parentElement.children enumerateObjectsUsingBlock:complete];
           }];
}

@end
