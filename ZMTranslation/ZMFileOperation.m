//
//  ZMFileOperation.m
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/30.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import "ZMFileOperation.h"

@implementation ZMFileOperation

+ (void)selectFile:(void (^)(NSInteger, NSString *))callback panel:(NSOpenPanel *)panel result:(NSInteger)result
{
    NSString *filePath = nil;
    if (result == NSModalResponseOK)
    {
        filePath = [panel.URLs.firstObject path];
    }
    if (callback) callback(result, filePath);
}

+ (void)selectFilePath:(void (^)(NSInteger response, NSString *filePath))callback
                window:(NSWindow *)window
             isPresent:(BOOL)isPresent
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    //是否可以创建文件夹
    panel.canCreateDirectories = YES;
    //是否可以选择文件夹
    panel.canChooseDirectories = YES;
    //是否可以选择文件
    panel.canChooseFiles = YES;

    //是否可以多选
    [panel setAllowsMultipleSelection:NO];

    __weak typeof(self) weakSelf = self;
    if (!isPresent)
    {
        //显示
        [panel beginSheetModalForWindow:window
                      completionHandler:^(NSModalResponse result) {
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          [strongSelf selectFile:callback panel:panel result:result];
                      }];
    }
    else
    {
        // 悬浮电脑主屏幕上
        [panel beginWithCompletionHandler:^(NSModalResponse result) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf selectFile:callback panel:panel result:result];
        }];
    }
}

@end
