//
//  GNSubject.m
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import "GNSubject.h"

@implementation GNSubject

@synthesize name = _name;
@synthesize url = _url;

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.url forKey:@"url"];
}

- (id)initWithCoder:(NSCoder*)coder {
    if (self = [super init]) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.url = [coder decodeObjectForKey:@"url"];
    }
    return self;
}

@end
