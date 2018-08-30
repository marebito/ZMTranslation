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

    NSArray *array = [vttContent componentsSeparatedByString:@"\n"];

    __block NSMutableString *finalString = [NSMutableString string];

    __block ZMSubtitle *sub = nil;
    __block NSMutableArray *subtitles = [[NSMutableArray alloc] init];
    __block NSInteger count = 0;
    [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj rangeOfString:@"WEBVTT"].location != NSNotFound)
        {
            // 直接写入
            NSLog(@"WEBVTT头");
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
                NSArray *result = __MREGEX__(obj, @"((\\d){2}:)(\\d){2}.(\\d){3}.{5}((\\d){2}:)(\\d){2}.(\\d){3}");
                if ([result count] > 0)
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
    [[ZMTranslateManager defaultManager] setEngine:kTranslateEngineGoogle];
    [subtitles enumerateObjectsUsingBlock:^(ZMSubtitle *subtitle, NSUInteger idx, BOOL *_Nonnull stop) {
        [subtitle.originText enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *_Nonnull stop) {
            [[ZMTranslateManager defaultManager]
                addTask:[ZMTranslateRequest
                            requestWithText:str
                                   callback:^(BOOL success, NSString *translateResult) {
                                       count--;
                                       [subtitle.transText setObject:translateResult forKey:str];
                                       if (count == 0)
                                       {
                                           NSString *finalString = [ZMSubtitleTranslator processSubtitles:subtitles];
                                           [ZMFileOperation
                                               selectFilePath:^(NSInteger response, NSString *filePath) {
                                                   NSString *vttPath = [filePath stringByAppendingPathComponent:@"test.vtt"];
                                                   if ([[NSFileManager defaultManager] removeItemAtPath:vttPath error:nil]) {
                                                       [finalString
                                                        writeToFile:vttPath
                                                        atomically:YES
                                                        encoding:NSUTF8StringEncoding
                                                        error:nil];
                                                   }
                                               }
                                                       window:[[NSApplication sharedApplication] mainWindow]
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
        [finalString appendString:subtitle.timestamp];
        [finalString appendString:@"\n"];
        [subtitle.originText enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *_Nonnull stop) {
            [finalString appendString:subtitle.transText[str]];
            [finalString appendString:@"\n"];
        }];
        [finalString appendString:@"\n"];
    }];
    return [finalString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
