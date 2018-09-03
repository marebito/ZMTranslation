//
//  ZMSentenceSplitter.m
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/8/31.
//  Copyright © 2018年 Yuri Boyka. All rights reserved.
//

#define SS_CANDIDATE @"(.*?)([\\S&&[^-:=+'\"\\(\\[\\{]]+[\\.!?][\"\'\\)\\]\\}>]*)(\\s+)(\\S+)(.*)"

#define SS_RULE0 @"\\S+[\\.!?][\"\'\\)\\]\\}>]+\\s+\\S+"

#define SS_RULE1 @"\\S+[!?]\\s+\\S+"

#define SS_RULE2 @"\\S+\\.\\s+\\p{Ll}\\S*"

#define SS_EWORDRULE @"[eim]\\p{Upper}\\p{Alpha}+"

#define SS_ABBREVIATIONS \
    @[                   \
       @"Dr.",           \
       @"Ph.D.",         \
       @"Ph.",           \
       @"Mr.",           \
       @"Mrs.",          \
       @"Ms.",           \
       @"Prof.",         \
       @"Esq.",          \
       @"Maj.",          \
       @"Gen.",          \
       @"Adm.",          \
       @"Lieut.",        \
       @"Lt.",           \
       @"Col.",          \
       @"Sgt.",          \
       @"Cpl.",          \
       @"Pte.",          \
       @"Cap.",          \
       @"Capt.",         \
       @"Sen.",          \
       @"Pres.",         \
       @"Rep.",          \
       @"St.",           \
       @"Rev.",          \
       @"Mt.",           \
       @"Rd.",           \
       @"Cres.",         \
       @"Ln.",           \
       @"Ave.",          \
       @"Av.",           \
       @"Bd.",           \
       @"Blvd.",         \
       @"Co.",           \
       @"co.",           \
       @"Ltd.",          \
       @"Plc.",          \
       @"PLC.",          \
       @"Inc.",          \
       @"Pty.",          \
       @"Corp.",         \
       @"Co.",           \
       @"et.",           \
       @"al.",           \
       @"ed.",           \
       @"eds.",          \
       @"Ed.",           \
       @"Eds.",          \
       @"Fig.",          \
       @"fig.",          \
       @"Ref.",          \
       @"ref.",          \
       @"etc.",          \
       @"usu.",          \
       @"e.g.",          \
       @"pp.",           \
       @"vs.",           \
       @"v.",            \
       @"yr.",           \
       @"yrs.",          \
       @"g.",            \
       @"mg.",           \
       @"kg.",           \
       @"gr.",           \
       @"lb.",           \
       @"lbs.",          \
       @"oz.",           \
       @"in.",           \
       @"mi.",           \
       @"m.",            \
       @"M.",            \
       @"mt.",           \
       @"mtr.",          \
       @"ft.",           \
       @"max.",          \
       @"min.",          \
       @"Max.",          \
       @"Min.",          \
       @"inc.",          \
       @"exc.",          \
       @"A.",            \
       @"B.",            \
       @"C.",            \
       @"D.",            \
       @"E.",            \
       @"F.",            \
       @"G.",            \
       @"H.",            \
       @"I.",            \
       @"J.",            \
       @"K.",            \
       @"L.",            \
       @"M.",            \
       @"N.",            \
       @"O.",            \
       @"P.",            \
       @"Q.",            \
       @"R.",            \
       @"S.",            \
       @"T.",            \
       @"U.",            \
       @"V.",            \
       @"W.",            \
       @"X.",            \
       @"Y.",            \
       @"Z.",            \
       @"a.",            \
       @"b.",            \
       @"c.",            \
       @"d.",            \
       @"e.",            \
       @"f.",            \
       @"g.",            \
       @"h.",            \
       @"i.",            \
       @"j.",            \
       @"k.",            \
       @"l.",            \
       @"m.",            \
       @"n.",            \
       @"o.",            \
       @"p.",            \
       @"q.",            \
       @"r.",            \
       @"s.",            \
       @"t.",            \
       @"u.",            \
       @"v.",            \
       @"w.",            \
       @"x.",            \
       @"y.",            \
       @"z.",            \
       @"Jan.",          \
       @"Feb.",          \
       @"Mar.",          \
       @"Apr.",          \
       @"Jun.",          \
       @"Jul.",          \
       @"Aug.",          \
       @"Sep.",          \
       @"Sept.",         \
       @"Oct.",          \
       @"Nov.",          \
       @"Dec.",          \
       @"Mon.",          \
       @"Tue.",          \
       @"Wed.",          \
       @"Thu.",          \
       @"Fri.",          \
       @"Sat.",          \
       @"Sun."           \
    ]

#define SS_LOWERCASETERMS \
    @[                    \
       @"mRNA",           \
       @"tRNA",           \
       @"cDNA",           \
       @"iPad",           \
       @"iPod",           \
       @"iPhone",         \
       @"iCloud",         \
       @"iMac",           \
       @"eCommerce",      \
       @"eBussiness",     \
       @"mCommerce",      \
       @"alpha",          \
       @"beta",           \
       @"gamma",          \
       @"delta",          \
       @"c",              \
       @"i",              \
       @"ii",             \
       @"iii",            \
       @"iv",             \
       @"v",              \
       @"vii",            \
       @"viii",           \
       @"ix",             \
       @"x"               \
    ]

#import "ZMSentenceSplitter.h"

@implementation ZMSentenceSplitter

+ (NSArray *)markupRawText:(NSString *)input
{
    NSMutableArray *sentenceList = [self splitParagraph:input];
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    NSInteger begin = 0, end = 0;
    NSInteger sentCount = 0;
    NSInteger parCount = 0;
    BOOL newPar = YES;
    for (int i = 0; i < sentenceList.count; i++)
    {
        NSString *sent = [sentenceList objectAtIndex:i];
        if ([sent isEqualToString:@""])
        {
            newPar = YES;
            parCount = (i == 0 ? 0 : parCount++);
        }
        else
        {
            begin = [self getStartOfSentRobustly:sent wholeDoc:input lastend:end];
            end = [self getEndOfSentRobustly:sent wholeDoc:input begin:begin];
            if (newPar)
            {
                newPar = NO;
            }
            NSArray *sentData = @[ @(parCount), @(sentCount), @(begin), @(end) ];
            [toReturn addObject:sentData];
            sentCount++;
        }
    }
    return toReturn;
}

+ (NSMutableArray<NSString *> *)splitParagraph:(NSString *)paragraph
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *remainder = [paragraph copy];
    NSMutableString *accumulator = [[NSMutableString alloc] init];
    NSString *test;

    while (remainder.length > 0)
    {
        NSArray *group = __DREGEX__(remainder, SS_CANDIDATE);
        if (group.count > 0)
        {
            [accumulator appendString:group[1]];
            [accumulator appendString:group[2]];
            test = [NSString stringWithFormat:@"%@%@%@", group[2], group[3], group[4]];
            remainder = [NSString stringWithFormat:@"%@%@%@", group[3], group[4], group[5]];
            NSArray *r0Result = __MREGEX__(test, SS_RULE0);
            NSArray *r1Result = __MREGEX__(test, SS_RULE1);
            NSArray *ewResult = __MREGEX__(group[4], SS_EWORDRULE);
            NSArray *r2Result = __MREGEX__(test, SS_RULE2);
            if ([SS_LOWERCASETERMS containsObject:group[4]] || r0Result.count > 0 || r1Result.count > 0 ||
                ewResult.count > 0)
            {
                [result addObject:accumulator];
                accumulator = [[NSMutableString alloc] init];
            }
            else if (r2Result.count > 0 && (![SS_ABBREVIATIONS containsObject:[group[2] lowercaseString]]) &&
                     (![SS_ABBREVIATIONS containsObject:group[2]]))
            {
                [result
                    addObject:[accumulator
                                  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                accumulator = [[NSMutableString alloc] init];
            }
        }
        else
        {
            [accumulator appendString:remainder];
            break;
        }
    }

    if (accumulator.length > 0)
    {
        [result
            addObject:[accumulator stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }

    return result;
}

+ (NSInteger)getStartOfSentRobustly:(NSString *)sent wholeDoc:(NSString *)wholeDoc lastend:(NSInteger)lastend
{
    NSArray *wordsOfSent = [sent componentsSeparatedByString:@" "];
    NSInteger begin = [[wholeDoc substringFromIndex:lastend] rangeOfString:wordsOfSent[0]].location;
    return lastend + begin;
}

+ (NSInteger)getEndOfSentRobustly:(NSString *)sent wholeDoc:(NSString *)wholeDoc begin:(NSInteger)begin
{
    NSArray *wordsOfSent = [sent componentsSeparatedByString:@" "];
    NSInteger start = begin, end = start;
    for (int i = 0; i < wordsOfSent.count; i++)
    {
        NSString *thisTok = [wordsOfSent objectAtIndex:i];
        NSRange range = [[wholeDoc substringFromIndex:end] rangeOfString:thisTok];
        end += range.location + range.length;
    }
    return end;
}

@end
