//
//  GNAppDelegate.h
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"

@interface GNAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) JASidePanelController *viewController;

@end
