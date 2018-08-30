//
//  ZMFileOperation.h
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/30.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface ZMFileOperation : NSObject

+ (void)selectFilePath:(void (^)(NSInteger response, NSString *filePath))callback
                window:(NSWindow *)window
             isPresent:(BOOL)isPresent;

@end
