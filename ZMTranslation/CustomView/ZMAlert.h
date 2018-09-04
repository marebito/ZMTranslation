//
//  ZMAlert.h
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/4/24.
//  Copyright © 2018年 Godlike Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 提示风格

 - kAlertStyleDefault: 模态风格
 - kAlertStyleSheet: 卷帘风格
 */
typedef NS_ENUM(NSUInteger, kAlertStyle) { kAlertStyleDefault, kAlertStyleSheet };

@interface ZMAlert : NSAlert

+ (ZMAlert *)alertWithStyle:(kAlertStyle)style
                   titles:(NSArray *)titles
                  message:(NSString *)message
              informative:(NSString *)informative
               clickBlock:(void (^)(ZMAlert *alert, NSUInteger index))block;

@end
