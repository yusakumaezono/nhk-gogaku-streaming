//
//  GNNhkAccessManager.m
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "GNNhkAccessManager.h"
#import "GDataXMLNode.h"
#import "NSData+Conversion.h"

@implementation GNNhkAccessManager

// hdateをキーとしたURLの配列を返す
+ (NSArray*)audioUrls:(GNSubject*)subject
{
    NSArray *mp4FileNames = [self mp4FileNames:subject];
    NSArray *audioUrls = [self urls:mp4FileNames];
    
    return audioUrls;
}

+ (NSArray*)mp4FileNames:(GNSubject *)subject
{
    NSString *urlStr = [NSString stringWithFormat:@"https://cgi2.nhk.or.jp/gogaku/%@/listdataflv.xml", subject.url];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data
                                                           options:0
                                                             error:nil];
    NSMutableArray *mp4FileNames = [[NSMutableArray alloc] init];
    NSArray *musics = [doc.rootElement elementsForName:@"music"];
    for (GDataXMLElement *music in musics) {
        NSDictionary *dict = @{@"hdate":[[music attributeForName:@"hdate"] stringValue],
                               @"file":[[music attributeForName:@"file"] stringValue]};
        [mp4FileNames addObject:dict];
    }
    
    return mp4FileNames;
}

+ (NSArray*)urls:(NSArray*)mp4FileNames
{
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in mp4FileNames) {
        NSString *fileName = [dict objectForKey:@"file"];
        NSString *url = [NSString stringWithFormat:@"https://nhk-vh.akamaihd.net/i/gogaku-stream/mp4/%@/master.m3u8", fileName];
        
        NSDictionary *urlDict = @{@"hdate":[dict objectForKey:@"hdate"], @"url":url};
        [urls addObject:urlDict];
    }
    return urls;
}

+ (void)downloadAndDecryptAudios:(NSURL*)url
{
    
    NSURL *indexM3u8Url = [self indexM3u8Url:url];
    NSArray *sourceUrls = [self sourceUrls:indexM3u8Url];
    NSString *decryptKey = [self decryptKey:sourceUrls[0]];
    NSArray *mp4files = [self saveTempMp4s:sourceUrls decryptKey:(NSString*)decryptKey];
    
    // デバッグ
    NSArray *files = [GNGlobal fileNames:[GNGlobal documentsPath]];
    for (NSString* fileName in files) {
        NSLog(@"%@", fileName);
    }
    
}

+ (NSURL*)indexM3u8Url:(NSURL*)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *dataStr= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@".m3u8Url=%@", dataStr);
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+"
                                                                           options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *arrayOfAllMatches = [regex matchesInString:dataStr options:0 range:NSMakeRange(0, dataStr.length)];
    
    NSMutableArray *arrayOfURLs = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSString* substringForMatch = [dataStr substringWithRange:match.range];
        [arrayOfURLs addObject:substringForMatch];
    }
    
    if (arrayOfURLs) {
        return [NSURL URLWithString:arrayOfURLs[0]];
    }
    
    return nil;
}

+ (NSArray*)sourceUrls:(NSURL*)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *dataStr= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+"
                                                                           options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *arrayOfAllMatches = [regex matchesInString:dataStr options:0 range:NSMakeRange(0, dataStr.length)];
    
    NSMutableArray *arrayOfURLs = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSString* substringForMatch = [dataStr substringWithRange:match.range];
        [arrayOfURLs addObject:substringForMatch];
    }
    
    return arrayOfURLs;
}

+ (NSString*)decryptKey:(NSString*)url
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    return [data hexadecimalString];
}

+ (NSArray*)saveTempMp4s:urls decryptKey:(NSString*)decryptKey
{
    NSLog(@"decryptKey=%@", decryptKey);
    
    NSString *mp4FilePath = [[GNGlobal documentsPath] stringByAppendingPathComponent:@"test.mp4"];
    [GNGlobal removeFileWithName:mp4FilePath];
    
    NSFileHandle *file;
    
    int i = 0;
    for (NSString *url in urls) {
        if (i != 0) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            NSString *iv = [NSString stringWithFormat:@"%032x", i];
            NSLog(@"id=%@", iv);
            
            NSMutableData *mp4Data = [GNGlobal AES128DecryptWithKey:data key:decryptKey iv:iv];
            
            if (![GNGlobal existsFileWithName:mp4FilePath]) {
                [mp4Data writeToFile:mp4FilePath atomically: YES];
            } else {
                file = [NSFileHandle fileHandleForWritingAtPath:mp4FilePath];
                [file seekToEndOfFile];
                [file writeData:mp4Data];
            }
        }
        i++;
    }
    
    [file closeFile];
    
    return nil;
}

@end
