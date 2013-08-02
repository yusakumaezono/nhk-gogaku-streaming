//
//  GNAppDelegate.m
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "GNAppDelegate.h"

@implementation GNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // JASidePanel
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Top" bundle:nil];
    UIStoryboard *menuStoryboard = [UIStoryboard storyboardWithName:@"Menu" bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.viewController = [[JASidePanelController alloc] init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
	self.viewController.leftPanel = [menuStoryboard instantiateInitialViewController];
	self.viewController.centerPanel = [mainStoryboard instantiateInitialViewController];
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // 音声をバックグラウンドで再生する
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 初期データ
    [self saveSubjectsToUserDefaults];
    
    return YES;
}

- (void)saveSubjectsToUserDefaults
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Subject" ofType:@"plist"];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
    NSMutableArray *subjects = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in [plist objectForKey:@"subjects"]) {
        GNSubject *subject = [[GNSubject alloc] init];
        subject.name = [dict objectForKey:@"name"];
        subject.url = [dict objectForKey:@"url"];
        [subjects addObject:subject];
    }
    [GNGlobal saveSubjectsToUserDefaults:subjects];
}

@end
