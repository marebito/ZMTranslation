//
//  ZMTranslateOperation.m
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/30.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import "ZMTranslateManager.h"

@implementation ZMTranslateRequest

+ (instancetype)requestWithText:(NSString *)text callback:(TranslateComplete)callback
{
    ZMTranslateRequest *request = [[ZMTranslateRequest alloc] init];
    request.originText = text;
    request.translateComplete = callback;
    return request;
}

@end

@interface ZMTranslateManager ()

@property(nonatomic, strong) NSOperationQueue *translateQueue;

@end

@implementation ZMTranslateManager

@synthesize translateQueue;

+ (ZMTranslateManager *)defaultManager
{
    static dispatch_once_t onceToken;
    static ZMTranslateManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[ZMTranslateManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        translateQueue = [[NSOperationQueue alloc] init];
        translateQueue.maxConcurrentOperationCount = TRANSLATE_MAX_CONCURRENT_COUNT;
    }
    return self;
}

- (void)addTask:(ZMTranslateRequest *)re
{
    ZMTranslateOperation *task = [[ZMTranslateOperation alloc] initWithReqeust:re];
    [translateQueue addOperation:task];
}

- (void)setMaxConcurrentOperationCount:(int)max { translateQueue.maxConcurrentOperationCount = max; }
- (void)dealloc { translateQueue = nil; }
@end

@implementation ZMTranslateOperation

- (id)initWithReqeust:(ZMTranslateRequest *)re
{
    if (nil != (self = [super init]))
    {
        self.request = re;
    }
    return self;
}

- (void)main
{
    [NSThread sleepForTimeInterval:1.0];
    [ZMWordTranslator tranlateWord:self.request.originText
                            engine:[ZMTranslateManager defaultManager].engine
                        completion:self.request.translateComplete];
}

@end
