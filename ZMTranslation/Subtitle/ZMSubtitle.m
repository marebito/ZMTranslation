//
//  ZMSubtitle.m
//  ZMSubtitleAutoTranslator
//
//  Created by Yuri Boyka on 2018/8/30.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import "ZMSubtitle.h"

@implementation ZMSubtitle

- (instancetype)init
{
    if (nil != (self = [super init]))
    {
        self.no = @"-1";
        self.timestamp = @"";
        self.originText = [[NSMutableArray alloc] init];
        self.transText = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
