//
//  ZMSubtitleTranslator.m
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/30.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import "ZMSubtitleTranslator.h"
#import "ZMSubtitle.h"
#import "ZMTranslateManager.h"
#import "ZMFileOperation.h"

@implementation ZMSubtitleTranslator

+ (void)translateSubtitle:(NSString *)vttFile
{
    NSString *vttContent = [[NSString alloc] initWithContentsOfFile:vttFile encoding:NSUTF8StringEncoding error:nil];
    NSString *fileName = [[vttFile lastPathComponent] stringByDeletingPathExtension];
    NSArray *array = [vttContent componentsSeparatedByString:@"\n"];

    __block NSMutableString *finalString = [NSMutableString string];

    __block ZMSubtitle *sub = nil;
    __block NSMutableArray *subtitles = [[NSMutableArray alloc] init];
    __block NSInteger count = 0;
    [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj rangeOfString:@"WEBVTT"].location != NSNotFound)
        {
            [finalString appendString:@"WEBVTT"];
        }
        else
        {
            if ([obj isEqualToString:@""])
            {
                if (sub)
                {
                    [subtitles addObject:sub];
                }
                sub = [[ZMSubtitle alloc] init];
                [finalString appendString:@"\n\n"];
            }
            else
            {
                NSArray *result = __MREGEX__(obj, WEBVTT_REGEX2);
                NSArray *isno = __MREGEX__(obj, WEBVTT_REGEX3);
                if ([isno count] > 0)
                {
                    sub.no = obj;
                    [finalString appendString:obj];
                    [finalString appendString:@"\n"];
                }
                else if ([result count] > 0)
                {
                    sub.timestamp = obj;
                    [finalString appendString:obj];
                    [finalString appendString:@"\n"];
                }
                else
                {
                    count++;
                    [sub.originText addObject:obj];
                    [finalString appendString:obj];
                    [finalString appendString:@"\n"];
                }
            }
        }
    }];
    NSInteger totalCount = count;
    [[ZMTranslateManager defaultManager] setEngine:kTranslateEngineGoogle];
    [subtitles enumerateObjectsUsingBlock:^(ZMSubtitle *subtitle, NSUInteger idx, BOOL *_Nonnull stop) {
        [[ZMTranslateManager defaultManager]
            addTask:[ZMTranslateRequest requestWithText:[subtitle.originText componentsJoinedByString:@" "]
                                               callback:^(BOOL success, NSString *translateResult) {
                                                   if (success)
                                                   {
                                                       subtitle.jointTranslate = translateResult;
                                                   }
                                               }]];
        [subtitle.originText enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *_Nonnull stop) {
            [[ZMTranslateManager defaultManager]
                addTask:[ZMTranslateRequest
                            requestWithText:str
                                   callback:^(BOOL success, NSString *translateResult) {
                                       if (!success)
                                       {
                                           NSLog(@"发生严重错误!!!");
                                       }
                                       count--;
                                       NSLog(@"进度-->%f", 1.0 - count*1.0/totalCount);
                                       [subtitle.transText setObject:translateResult forKey:str];
                                       if (count == 0)
                                       {
                                           // TODO: 字幕人工校验
                                           NSString *finalString = [ZMSubtitleTranslator processSubtitles:subtitles];
                                           [ZMFileOperation selectFilePath:^(NSInteger response, NSString *filePath) {
                                               NSString *vttPath = [filePath
                                                   stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.vtt",
                                                                                                             fileName]];
                                               if ([[NSFileManager defaultManager] fileExistsAtPath:vttPath])
                                               {
                                                   [[NSFileManager defaultManager] removeItemAtPath:vttPath error:nil];
                                               }
                                               [finalString writeToFile:vttPath
                                                             atomically:YES
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];
                                           }
                                                                    window:[[NSApplication sharedApplication]
                                                                               mainWindow]
                                                                 isPresent:YES];
                                       }
                                   }]];
        }];
    }];
}

+ (NSString *)processSubtitles:(NSArray *)subtitles
{
    NSMutableString *finalString = [[NSMutableString alloc] init];
    [finalString appendString:@"WEBVTT"];
    [finalString appendString:@"\n\n"];
    [subtitles enumerateObjectsUsingBlock:^(ZMSubtitle *subtitle, NSUInteger subtitleIdx, BOOL *_Nonnull stop) {
        __block NSMutableString *translateJointString = [[NSMutableString alloc] init];
        [subtitle.originText enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *_Nonnull stop) {
            [translateJointString appendString:subtitle.transText[str]];
        }];
        subtitle.similarity = [NSString sim:translateJointString str2:subtitle.jointTranslate];
        if ([subtitle.no integerValue] != -1)
        {
            [finalString appendString:subtitle.no];
            [finalString appendString:@"\n"];
        }
        [finalString appendString:subtitle.timestamp];
        [finalString appendString:@"\n"];
        if (subtitle.similarity >= 0.7)
        {
            [subtitle.originText enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *_Nonnull stop) {
                [finalString appendString:subtitle.transText[str]];
                [finalString appendString:@"\n"];
            }];
        }
        else
        {
            [finalString appendString:translateJointString];
            [finalString appendString:@"\n"];
        }
        [finalString appendString:@"\n"];
    }];
    return [finalString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
