//
//  GNBaseViewController.m
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import "GNBaseViewController.h"

@interface GNBaseViewController ()

@end

@implementation GNBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor peterRiverColor]
                                  highlightedColor:[UIColor belizeHoleColor]
                                      cornerRadius:3
                                   whenContainedIn:[UINavigationBar class], nil];
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
}

- (void)setTitleLabel:(NSString*)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationItem.titleView.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldFlatFontOfSize:18];
    label.textColor =[UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    self.navigationItem.titleView = label;
}

@end
