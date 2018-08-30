//
//  Subtitle.h
//  ZMSubtitleAutoTranslator
//
//  Created by Yuri Boyka on 2018/8/30.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZMSubtitle : NSObject

@property(nonatomic, copy) NSString *timestamp;
@property(nonatomic, strong) NSMutableArray *originText;
@property(nonatomic, strong) NSMutableDictionary *transText;

@end
