//
//  GNNhkAccessManager.h
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GNNhkAccessManager : NSObject

+ (NSArray*)audioUrls:(GNSubject*)subject;
+ (void)downloadAndDecryptAudios:(NSURL*)url;

@end
