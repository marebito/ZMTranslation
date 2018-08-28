//
//  AlertView.m
//  BaiduDownloader
//
//  Created by zll on 2018/4/24.
//  Copyright © 2018年 Godlike Studio. All rights reserved.
//

#import "Alert.h"

@implementation Alert

+ (Alert *)alertWithStyle:(kAlertStyle)style
                   titles:(NSArray *)titles
                  message:(NSString *)message
              informative:(NSString *)informative
               clickBlock:(void (^)(Alert *alert, NSUInteger index))block
{
    Alert *alert = [[Alert alloc] init];
    for (NSString *title in titles)
    {
        [alert addButtonWithTitle:title];
    }
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setMessageText:message];
    [alert setInformativeText:informative];
    switch (style)
    {
        case kAlertStyleDefault:
        {
            NSUInteger action = [alert runModal];
            if (block) block(alert, action);
        }
        break;
        case kAlertStyleSheet:
        {
            [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                          completionHandler:^(NSInteger result) {
                              if (block) block(alert, result);
                          }];
        }
        break;
        default:
            break;
    }
    return alert;
}

@end
