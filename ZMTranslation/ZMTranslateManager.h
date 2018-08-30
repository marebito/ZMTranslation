//
//  ZMTranslateOperation.h
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/30.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMWordTranslator.h"

typedef void (^TranslateComplete)(BOOL success, NSString *translateResult);

#define TRANSLATE_MAX_CONCURRENT_COUNT 1

@interface ZMTranslateRequest : NSObject

@property(nonatomic, copy) NSString *originText;

//@property(nonatomic, copy) void (^translateComplete)(BOOL success, NSString *translateResult);

@property(nonatomic, copy) TranslateComplete translateComplete;

+ (instancetype)requestWithText:(NSString *)text callback:(TranslateComplete)callback;

@end

@interface ZMTranslateOperation : NSOperation

@property(nonatomic, strong) ZMTranslateRequest *request;

- (id)initWithReqeust:(ZMTranslateRequest *)re;

@end

@interface ZMTranslateManager : NSObject

+ (ZMTranslateManager *)defaultManager;

@property(nonatomic, assign) kTranslateEngine engine;

- (void)addTask:(ZMTranslateRequest *)re;

- (void)setMaxConcurrentOperationCount:(int)max;

@end
