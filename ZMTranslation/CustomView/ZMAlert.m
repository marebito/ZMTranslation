//
//  ZMAlert.m
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/4/24.
//  Copyright © 2018年 Godlike Studio. All rights reserved.
//

#import "ZMAlert.h"

@implementation ZMAlert

+ (ZMAlert *)alertWithStyle:(kAlertStyle)style
                   titles:(NSArray *)titles
                  message:(NSString *)message
              informative:(NSString *)informative
               clickBlock:(void (^)(ZMAlert *alert, NSUInteger index))block
{
    ZMAlert *alert = [[ZMAlert alloc] init];
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
