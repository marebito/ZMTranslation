//
//  ViewController.m
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/27.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#import "ViewController.h"
#import "WordTranslator.h"
#import "Alert.h"

// E-欧路 I-ICBA G-google T-腾讯 B-百度 Y-有道

@interface ViewController ()

@property(nonatomic, strong) NSMutableDictionary *cacheTranslate;

@property(unsafe_unretained) IBOutlet NSTextView *originTextView;

@property(unsafe_unretained) IBOutlet NSTextView *translateTextView;

@property(weak) IBOutlet NSSegmentedControl *translateSegment;

@end

@implementation ViewController

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
        [Alert alertWithStyle:kAlertStyleSheet
                       titles:@[ @"确定" ]
                      message:@"请输入原文!!!"
                  informative:@"重试!"
                   clickBlock:^(Alert *alert, NSUInteger index){

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
            engine = kTranslateEngineTencent;
            break;
        case 4:
            engine = kTranslateEngineBaidu;
            break;
        case 5:
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
        case kTranslateEngineTencent:
            transKey = @"T";
            break;
        case kTranslateEngineBaidu:
            transKey = @"B";
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
    [WordTranslator tranlateWord:str
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
                              [Alert alertWithStyle:kAlertStyleSheet
                                             titles:@[ @"确定" ]
                                            message:@"发生严重错误，请重试!!!"
                                        informative:result
                                         clickBlock:nil];
                          }
                      }];
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

@end
