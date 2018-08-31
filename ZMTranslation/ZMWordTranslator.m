//
//  ZMWordTranslator.m
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/27.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import "ZMWordTranslator.h"
#import "AFNetworking.h"
#import "HttpUtil.h"

@implementation ZMWordTranslator

+ (void)tranlateWord:(NSString *)word
              engine:(kTranslateEngine)engine
          completion:(void (^)(BOOL success, NSString *result))completion
{
    NSString *url = nil;
    NSString *method = @"POST";
    NSString *host = nil;
    NSString *origin = nil;
    NSString *referer = nil;
    NSDictionary *param = nil;
    NSMutableDictionary *headerInfo = [HttpUtil commonHeader];
    switch (engine)
    {
        case kTranslateEngineEudic:
        {
            url = EUDIC_TRANSLATE_URL;
            host = EUDIC_TRANSLATE_HOST;
            origin = EUDIC_TRANSLATE_ORIGIN;
            referer = EUDIC_TRANSLATE_REFERER;
            param = @{ @"from" : @"en", @"to" : @"zh-CN", @"text" : word, @"contentType" : @"text/plain" };
        }
        break;
        case kTranslateEngineIcba:
        {
            url = ICBA_TRANSLATE_URL;
            host = ICBA_TRANSLATE_HOST;
            origin = ICBA_TRANSLATE_ORIGIN;
            referer = ICBA_TRANSLATE_REFERER;
            param = @{ @"f" : @"auto", @"t" : @"auto", @"w" : word };
        }
        break;
        case kTranslateEngineGoogle:
        {
            url = GOOGLE_TRANSLATE_URL;
            method = @"GET";
            referer = GOOGLE_TRANSLATE_URL;
            param = @{
                @"client" : @"t",
                @"sl" : @"en",
                @"tl" : @"zh-CN",
                @"hl" : @"en",
                @"dt" : @"at",
                @"dt" : @"bd",
                @"dt" : @"ex",
                @"dt" : @"ld",
                @"dt" : @"md",
                @"dt" : @"qca",
                @"dt" : @"rw",
                @"dt" : @"rm",
                @"dt" : @"ss",
                @"dt" : @"t",
                @"ie" : @"UTF-8",
                @"oe" : @"UTF-8",
                @"otf" : @"1",
                @"pc" : @"1",
                @"ssel" : @"0",
                @"tsel" : @"0",
                @"kc" : @"2",
                @"tk" : @"342694.244574",
                @"q" : word
            };
        }
        break;
        case kTranslateEngineTencent:
        {
            url = TENCENT_TRANSLATE_URL;
            host = TENCENT_TRANSLATE_HOST;
            origin = TENCENT_TRANSLATE_ORIGIN;
            referer = TENCENT_TRANSLATE_REFERER;
            param = @{
                @"source" : @"en",
                @"target" : @"zh",
                @"sourceText" : word,
            };
        }
        break;
        case kTranslateEngineBaidu:
        {
            url = BAIDU_TRANSLATE_URL;
            host = BAIDU_TRANSLATE_HOST;
            origin = BAIDU_TRANSLATE_ORIGIN;
            referer = BAIDU_TRANSLATE_REFERER;
            param = @{
                @"from" : @"en",
                @"to" : @"zh",
                @"query" : word,
                @"transtype" : @"realtime",
                @"simple_means_flag" : @"3",
            };
            [headerInfo setObject:@"Mozilla/5.0 (Linux; Android 5.1.1; Nexus 6 Build/LYZ28E) AppleWebKit/537.36 "
                                  @"(KHTML, like Gecko) Chrome/63.0.3239.84 Mobile Safari/537.36"
                           forKey:@"User-Agent"];
        }
        break;
        case kTranslateEngineYouDao:
        {
            url = YOUDAO_TRANSLATE_URL;
            host = YOUDAO_TRANSLATE_HOST;
            origin = YOUDAO_TRANSLATE_ORIGIN;
            referer = YOUDAO_TRANSLATE_REFERER;
            param = @{
                @"i" : word,
                @"from" : @"AUTO",
                @"to" : @"AUTO",
                @"smartresult" : @"dict",
                @"client" : @"fanyideskweb",
                @"doctype" : @"json",
                @"version" : @"2.1",
                @"keyfrom" : @"fanyi.web",
                @"action" : @"FY_BY_REALTIME",
                @"typoResult" : @"false"
            };
        }
        break;
        default:
            break;
    }
    if (host)
    {
        [headerInfo setObject:host forKey:@"Host"];
    }
    if (origin)
    {
        [headerInfo setObject:origin forKey:@"Origin"];
    }
    if (referer)
    {
        [headerInfo setObject:referer forKey:@"referer"];
    }

    [HttpUtil request:url
               method:method
              headers:headerInfo
               params:param
           completion:^(NSURLResponse *response, id responseObject, NSError *error) {
               if (!error)
               {
                   NSString *result = nil;
                   switch (engine)
                   {
                       case kTranslateEngineEudic:
                       {
                           result = __RD__(responseObject);
                           result = [result stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
                       }
                       break;
                       case kTranslateEngineIcba:
                       {
                           NSDictionary *jsonDic = __JSONDIC__(responseObject);
                           result = jsonDic[@"content"][@"out"];
                       }
                       break;
                       case kTranslateEngineGoogle:
                       {
                           result = __RD__(responseObject);
                           result = __VREGEX__(result, @"TRANSLATED_TEXT='", @";");
                           result = [result stringByReplacingOccurrencesOfString:@"\\x3cbr\\x3e" withString:@"\n"];
                           result = [result substringToIndex:result.length - 1];
                       }
                       break;
                       case kTranslateEngineTencent:
                       {
                           result = [ZMWordTranslator parseTranslateResult:responseObject
                                                                    keys:@[ @"translate", @"records" ]
                                                                transKey:@"targetText"];
                       }
                       break;
                       case kTranslateEngineBaidu:
                       {
                           result = [ZMWordTranslator parseTranslateResult:responseObject
                                                                    keys:@[ @"phonetic" ]
                                                                transKey:@"src_str"];
                       }
                       break;
                       case kTranslateEngineYouDao:
                       {
                           result = [ZMWordTranslator parseTranslateResult:responseObject
                                                                    keys:@[ @"translateResult" ]
                                                                transKey:@"tgt"];
                       }
                       break;
                       default:
                           break;
                   }
                   completion(YES, result);
               }
               else
               {
                   completion(NO, [error description]);
               }
           }];
}

+ (NSString *)parseTranslateResult:(id)responseObject keys:(NSArray *)keys transKey:(NSString *)transKey
{
    NSDictionary *jsonDic = __JSONDIC__(responseObject);
    id data = jsonDic[keys[0]];
    if ([data isKindOfClass:[NSDictionary class]])
    {
        data = data[keys[1]];
    }
    NSMutableString *string = [NSMutableString string];
    [data enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]])
        {
            [string appendString:obj[0][transKey]];
        }
        else
        {
            [string appendString:obj[transKey]];
        }
    }];
    return [NSString stringWithString:string];
}

@end