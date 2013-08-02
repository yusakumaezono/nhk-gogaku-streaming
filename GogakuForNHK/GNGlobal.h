//
//  GNGlobal.h
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import <Foundation/Foundation.h>

@interface GNGlobal : NSObject

+ (NSArray*)subjectsFromUserDefaults;
+ (void)saveSubjectsToUserDefaults:(NSArray*)subjects;
+ (void)showFirstLaunchAlert;

+ (NSString*)documentsPath;
+ (NSString*)tempPath;
+ (NSArray*)fileNames:(NSString*)path;
+ (BOOL)existsFileWithName:(NSString*)path;
+ (void)makeDir:(NSString*)path;
+ (void)removeFileWithName:(NSString*)path;

+ (NSData*)AES128EncryptWithKey:(NSData*)data key:(NSString*)key iv:(NSString*)iv;
+ (NSMutableData*)AES128DecryptWithKey:(NSData*)data key:(NSString*)key iv:(NSString*)iv;

@end
