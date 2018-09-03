//
//  ZMWordTranslator.h
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/27.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 翻译引擎

 - kTranslateEngineEudic: 欧路词典
 - kTranslateEngineIcba: 爱词霸
 - kTranslateEngineGoogle: 谷歌翻译
 - kTranslateEngineBing: 必应翻译
 - kTranslateEngineTencent: 腾讯翻译
 - kTranslateEngineBaidu: 百度翻译
 - kTranslateEngineYouDao: 有道翻译
 */
typedef NS_ENUM(NSUInteger, kTranslateEngine) {
    kTranslateEngineEudic,
    kTranslateEngineIcba,
    kTranslateEngineGoogle,
    kTranslateEngineBing,
    kTranslateEngineTencent,
    kTranslateEngineBaidu,
    kTranslateEngineYouDao
};

@interface ZMWordTranslator : NSObject

+ (void)tranlateWord:(NSString *)word
              engine:(kTranslateEngine)engine
          completion:(void (^)(BOOL success, NSString *result))completion;

+ (void)translateLongWord:(NSString *)word
                   engine:(kTranslateEngine)engine
                segmented:(BOOL)segmented
               completion:(void (^)(NSString *result))completion;

@end
