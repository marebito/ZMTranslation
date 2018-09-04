//
//  ViewController.m
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/27.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import "ViewController.h"
#import "ZMWordTranslator.h"
#import "ZMAlert.h"
#import "ZMSubtitleTranslator.h"
#import "ZMDragDropView.h"

// E-欧路 I-ICBA G-google B-Bing T-腾讯 BD-百度 Y-有道

@interface ViewController ()<ZMDragDropViewDelegate>

@property(nonatomic, strong) NSMutableDictionary *cacheTranslate;

@property(unsafe_unretained) IBOutlet NSTextView *originTextView;

@property(unsafe_unretained) IBOutlet NSTextView *translateTextView;

@property(weak) IBOutlet NSSegmentedControl *translateSegment;

@end

@implementation ViewController

- (NSArray *)getLastIndexes:(NSArray *)tmpArray
{
    NSMutableArray *splitIndexes = [NSMutableArray arrayWithObject:@(0)];
    __block NSUInteger lastIndex = 0;
    __block NSUInteger indexOffset = 0;
    [tmpArray enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj[2] longLongValue] - indexOffset > 5000)
        {
            indexOffset = [obj[2] longLongValue];
            [splitIndexes addObject:@(lastIndex)];
        }
        else if ([obj[3] longLongValue] - indexOffset > 5000)
        {
            indexOffset = [obj[2] longLongValue];
            [splitIndexes addObject:@(lastIndex)];
        }
        lastIndex = idx;
        if (lastIndex == tmpArray.count - 1)
        {
            [splitIndexes addObject:@(lastIndex)];
        }
    }];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < splitIndexes.count - 1; i++)
    {
        NSRange range =
            NSMakeRange([splitIndexes[i] unsignedIntegerValue],
                        ([splitIndexes[i + 1] unsignedIntegerValue] - [splitIndexes[i] unsignedIntegerValue] + 1));
        if ([splitIndexes[i] unsignedIntegerValue] > 0)
        {
            range = NSMakeRange([splitIndexes[i] unsignedIntegerValue] + 1,
                                ([splitIndexes[i + 1] unsignedIntegerValue] - [splitIndexes[i] unsignedIntegerValue]));
        }
        [resultArray addObject:[[tmpArray copy] subarrayWithRange:range]];
    }
    return [NSArray arrayWithArray:resultArray];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cacheTranslate = [[NSMutableDictionary alloc] init];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor =
        [NSColor colorWithRed:58.0 / 255.0 green:61.0 / 255.0 blue:63.0 / 255.0 alpha:1.0].CGColor;
    self.originTextView.textColor = [NSColor colorWithRed:145 / 255.0 green:125 / 255.0 blue:82 / 255.0 alpha:1.0];
    self.translateTextView.textColor = [NSColor colorWithRed:94 / 255.0 green:111 / 255.0 blue:79 / 255.0 alpha:1.0];
}

- (void)viewDidAppear { [super viewDidAppear]; }
- (void)setRepresentedObject:(id)representedObject { [super setRepresentedObject:representedObject]; }
- (IBAction)segmentClicked:(id)sender
{
    NSSegmentedControl *segCtl = (NSSegmentedControl *)sender;
    if (self.originTextView.string.length == 0)
    {
        [ZMAlert alertWithStyle:kAlertStyleSheet
                         titles:@[ @"确定" ]
                        message:@"请输入原文!!!"
                    informative:@"重试!"
                     clickBlock:^(ZMAlert *alert, NSUInteger index){

                     }];
        return;
    }
    kTranslateEngine engine = kTranslateEngineEudic;
    switch (segCtl.selectedSegment)
    {
        case 0:
            engine = kTranslateEngineEudic;
            break;
        case 1:
            engine = kTranslateEngineIcba;
            break;
        case 2:
            engine = kTranslateEngineGoogle;
            break;
        case 3:
            engine = kTranslateEngineBing;
            break;
        case 4:
            engine = kTranslateEngineTencent;
            break;
        case 5:
            engine = kTranslateEngineBaidu;
            break;
        case 6:
            engine = kTranslateEngineYouDao;
            break;
        default:
            break;
    }
    [self translateWord:self.originTextView.string engine:engine];
}

- (void)translateWord:(NSString *)str engine:(kTranslateEngine)engine
{
    NSMutableDictionary *dic = _cacheTranslate[str];
    NSString *transKey = @"E";
    switch (engine)
    {
        case kTranslateEngineEudic:
            transKey = @"E";
            break;
        case kTranslateEngineIcba:
            transKey = @"I";
            break;
        case kTranslateEngineGoogle:
            transKey = @"G";
            break;
        case kTranslateEngineBing:
            transKey = @"B";
            break;
        case kTranslateEngineTencent:
            transKey = @"T";
            break;
        case kTranslateEngineBaidu:
            transKey = @"BD";
            break;
        case kTranslateEngineYouDao:
            transKey = @"Y";
            break;
        default:
            break;
    }
    if (dic)
    {
        NSString *result = dic[transKey];
        if (result.length > 0)
        {
            self.translateTextView.string = result;
            return;
        }
    }
    __weak typeof(self) weakSelf = self;
    if (self.originTextView.string.length > 5000)
    {
        [ZMWordTranslator translateLongWord:str
                                     engine:engine
                                  segmented:NO
                                 completion:^(NSString *result) {
                                     __strong typeof(self) strongSelf = weakSelf;
                                     if (dic)
                                     {
                                         dic[transKey] = result;
                                     }
                                     else
                                     {
                                         NSMutableDictionary *transDic = [NSMutableDictionary dictionary];
                                         transDic[transKey] = result;
                                         strongSelf.cacheTranslate[str] = transDic;
                                     }
                                     strongSelf.translateTextView.string = result;
                                 }];
    }
    else
    {
        [ZMWordTranslator tranlateWord:str
                                engine:engine
                            completion:^(BOOL success, NSString *result) {
                                __strong typeof(self) strongSelf = weakSelf;
                                if (success)
                                {
                                    if (dic)
                                    {
                                        dic[transKey] = result;
                                    }
                                    else
                                    {
                                        NSMutableDictionary *transDic = [NSMutableDictionary dictionary];
                                        transDic[transKey] = result;
                                        strongSelf.cacheTranslate[str] = transDic;
                                    }
                                    strongSelf.translateTextView.string = result;
                                }
                                else
                                {
                                    [ZMAlert alertWithStyle:kAlertStyleSheet
                                                     titles:@[ @"确定" ]
                                                    message:@"发生严重错误，请重试!!!"
                                                informative:result
                                                 clickBlock:nil];
                                }
                            }];
    }
}

- (NSString *)pasteBoardContent
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    if ([[pasteboard types] containsObject:NSPasteboardTypeString])
    {
        NSString *pasteBoardContent = [NSString
            stringWithFormat:@"%@ ",
                             [[pasteboard stringForType:NSPasteboardTypeString]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        return pasteBoardContent;
    }
    return @"";
}

- (IBAction)pasteOrigin:(id)sender
{
    NSString *content = [self pasteBoardContent];
    if (![content isEqualToString:self.originTextView.string])
    {
        self.originTextView.string = content;
        self.translateTextView.string = @"";
        [self.translateSegment setSelectedSegment:0];
        [self segmentClicked:self.translateSegment];
    }
}

- (IBAction)copyResult:(id)sender
{
    if (self.translateTextView.string.length > 0)
    {
        NSPasteboard *paste = [NSPasteboard generalPasteboard];
        [paste clearContents];
        [paste writeObjects:@[ self.translateTextView.string ]];

        self.originTextView.string = @"";
        self.translateTextView.string = @"";
    }
}

/***
 第五步：实现dragdropview的代理函数，如果有数据返回就会触发这个函数
 ***/
- (void)dragDropViewFileList:(NSArray *)fileList
{
    //如果数组不存在或为空直接返回不做处理（这种方法应该被广泛的使用，在进行数据处理前应该现判断是否为空。）
    if (!fileList || [fileList count] <= 0) return;
    //在这里我们将遍历这个数字，输出所有的链接，在后台你将会看到所有接受到的文件地址
    for (int n = 0; n < [fileList count]; n++)
    {
        NSLog(@">>> %@", [fileList objectAtIndex:n]);
        [ZMSubtitleTranslator translateSubtitle:fileList[0]];
    }
}

@end
