//
//  GNGlobal.m
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import "GNGlobal.h"

@implementation GNGlobal

+ (NSArray*)subjectsFromUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = (NSData*)[defaults objectForKey:@"subjects"];
    NSMutableArray *list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (list == nil) {
        list = [[NSMutableArray alloc] init];
    }
    
    return list;
}

+ (void)saveSubjectsToUserDefaults:(NSArray*)subjects
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:subjects];
    [defaults setObject:data forKey:@"subjects"];
    [defaults synchronize];
}

#pragma mark - Alert

+ (void)showFirstLaunchAlert
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"お知らせ"
                                                          message:@"NHK側の変更などにより、音声が正しく再生できない場合があります。障害情報は「サポート・障害情報」のページに掲載します。"
                                                         delegate:nil
                                                cancelButtonTitle:@"閉じる"
                                                otherButtonTitles:nil, nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    
    [alertView show];
}

#pragma mark - Shortcut

+ (NSString*)documentsPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

+ (NSString*)tempPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
}

#pragma mark - Encrypt / Decrypt

+ (NSMutableData*)AES128Operation:(CCOperation)operation data:(NSData*)data key:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES256 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES256 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    } else {
        NSLog(@"CCCrypt status: %d", cryptStatus);
    }
    free(buffer);
    return nil;
}

+ (NSData*)AES128EncryptWithKey:(NSData*)data key:(NSString*)key iv:(NSString*)iv
{
    return [self AES128Operation:kCCEncrypt data:data key:key iv:iv];
}

+ (NSMutableData*)AES128DecryptWithKey:(NSData*)data key:(NSString*)key iv:(NSString*)iv
{
    return [self AES128Operation:kCCDecrypt data:data  key:key iv:iv];
}

#pragma mark - NSFileManager

//ファイル一覧の取得
+ (NSArray*)fileNames:(NSString*)path
{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
}

//ファイル・ディレクトリが存在するか
+ (BOOL)existsFileWithName:(NSString*)path
{
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

//ディレクトリの生成
+ (void)makeDir:(NSString*)path
{
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
}

//ファイル・ディレクトリの削除
+ (void)removeFileWithName:(NSString*)path
{
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
