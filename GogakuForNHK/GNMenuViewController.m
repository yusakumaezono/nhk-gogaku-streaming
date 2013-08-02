//
//  GNMenuViewController.m
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import "GNMenuViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "GNTopViewController.h"
#import "AAMFeedbackViewController.h"
#import "GNNhkAccessManager.h"

static int sectionSubjects = 0;
static int sectionAbout = 1;

@interface GNMenuViewController ()

@property (nonatomic, retain) NSArray *subjects;
@property (nonatomic, retain) GNSubject *selectedSubject;
@property (nonatomic, retain) NSArray *selectedAudios;

@end

@implementation GNMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.subjects = [GNGlobal subjectsFromUserDefaults];
    
    // ナビゲーションバーの設定
    [self setNavigationItems];
    
    // 初回起動時にメッセージを表示する
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLaunchDone"]) {
        [GNGlobal showFirstLaunchAlert];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLaunchDone"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    // 通知設定
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // 開発者情報の取得が完了した通知
    [nc addObserver:self
           selector:@selector(didGetAudioUrls:)
               name:@"didGetAudioUrls" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)setNavigationItems
{
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor peterRiverColor]
                                  highlightedColor:[UIColor belizeHoleColor]
                                      cornerRadius:3
                                   whenContainedIn:[UINavigationBar class], nil];
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    
    self.tableView.separatorColor = [UIColor grayColor];
    self.tableView.backgroundColor = [UIColor cloudsColor];
    self.tableView.backgroundView = nil;
    
    self.title = @"";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == sectionSubjects) {
        return self.subjects.count;
    } else if (section == sectionAbout) {
        return 3;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    headerView.backgroundColor = [UIColor greenSeaColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 10, 20)];
    label.font = [UIFont boldFlatFontOfSize:12];
    label.textColor = [UIColor cloudsColor];
    label.backgroundColor = [UIColor greenSeaColor];
    
    if (section == sectionSubjects) {
        label.text = @"講座名";
    } else if (section == sectionAbout) {
        label.text = @"このアプリについて";
    }
    
    [headerView addSubview:label];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
    cell.textLabel.font = [UIFont boldFlatFontOfSize:14];
    
    if (indexPath.section == sectionSubjects) {
        GNSubject *subject = self.subjects[indexPath.row];
        cell.textLabel.text = subject.name;
    } else if (indexPath.section == sectionAbout && indexPath.row == 0) {
        cell.textLabel.text = @"不具合報告・ご意見";
    } else if (indexPath.section == sectionAbout && indexPath.row == 1) {
        cell.textLabel.text = @"サポート・障害情報";
    } else if (indexPath.section == sectionAbout && indexPath.row == 2) {
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"バージョン (%@)",
                               [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        return cell;

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == sectionSubjects) {
        self.selectedSubject = self.subjects[indexPath.row];
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperationWithBlock:^{
            self.selectedAudios = [GNNhkAccessManager audioUrls:self.selectedSubject];
            
            NSNotification *n = [NSNotification notificationWithName:@"didGetAudioUrls" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:n];
        }];
    } else if (indexPath.section == sectionAbout && indexPath.row == 0) {
        // 不具合報告・ご意見
        AAMFeedbackViewController *vc = [[AAMFeedbackViewController alloc]init];
        vc.toRecipients = [NSArray arrayWithObject:FEEDBACK_MAIL_ADDRESS];
        vc.ccRecipients = nil;
        vc.bccRecipients = nil;
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:nil];
    } else if (indexPath.section == sectionAbout && indexPath.row == 1) {
        // サポート・障害情報
        NSURL *url = [NSURL URLWithString:SUPPORT_URL];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)showTopTapped {
    UIStoryboard *topStoryboard = [UIStoryboard storyboardWithName:@"Top" bundle:nil];
    UINavigationController *navigationController = [topStoryboard instantiateInitialViewController];
    [(GNTopViewController*)navigationController.topViewController setSubject:self.selectedSubject];
    [(GNTopViewController*)navigationController.topViewController setAudios:self.selectedAudios];
    self.sidePanelController.centerPanel = navigationController;
    [self showCenterPanel];
}

#pragma mark - Notification

- (void)didGetAudioUrls:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        
        [self showTopTapped];
    });
}

#pragma mark - Table view delegate

- (void)hideCenterPanel {
    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.2f];
}

- (void)showCenterPanel {
    [self.sidePanelController setCenterPanelHidden:NO animated:YES duration:0.2f];
}

@end
