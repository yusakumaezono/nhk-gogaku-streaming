//
//  GNTopViewController.h
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNBaseViewController.h"

@interface GNTopViewController : GNBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) GNSubject *subject;
@property (nonatomic, retain) NSArray *audios;

@end
