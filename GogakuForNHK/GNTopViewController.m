//
//  GNTopViewController.m
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/28.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import "GNTopViewController.h"
#import "AVPlayerViewController.h"
#import "GNNhkAccessManager.h"
#import "GNAudioCell.h"

@interface GNTopViewController ()

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation GNTopViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ナビゲーションバーの設定
    [self setNavigationItems];
    
    // テーブルビューを表示
    [self addTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if (self.subject) {
        self.title = self.subject.name;
    }
}

#pragma mark - Setting View

- (void)setNavigationItems
{
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    // タイトル
    [super setTitleLabel:@"語学学習 for NHK"];
    
    // ナビゲーションの下に不要な空行が表示されるため
    self.view.frame = self.view.bounds;
}

// テーブルビューを表示する
- (void)addTableView
{
    CGRect rect = self.view.frame;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 150.f, 0.f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.f, 0.f, 50.f, 0.f);
    self.tableView.allowsSelectionDuringEditing = YES;
    [self.view addSubview:self.tableView];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.audios.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    GNAudioCell *cell = (GNAudioCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        UINib* nib = [UINib nibWithNibName:@"GNAudioCell" bundle:nil];
        NSArray* array = [nib instantiateWithOwner:nil options:nil];
        cell = [array objectAtIndex:0];
        
        cell.dateLable.font = [UIFont boldFlatFontOfSize:14];
        
        [cell.playButton addTarget:self
                            action:@selector(playButtonTapped:event:)
                  forControlEvents:UIControlEventTouchUpInside];

        [cell.downloadButton addTarget:self
                                action:@selector(downloadButtonTapped:event:)
                      forControlEvents:UIControlEventTouchUpInside];
    }

    NSDictionary *audioDict = self.audios[indexPath.row];
    cell.dateLable.text = [audioDict objectForKey:@"hdate"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}

- (void)playButtonTapped:(id)sender event:(id)event
{
    CGPoint touchPosition = [[[event allTouches] anyObject] locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPosition];
    if (indexPath != nil) {
        NSDictionary *audioDict = self.audios[indexPath.row];
        NSURL *audioURL = [NSURL URLWithString:[audioDict objectForKey:@"url"]];
        [self.navigationController pushViewController:[AVPlayerViewController controller:audioURL] animated:YES];
    }
}

- (void)downloadButtonTapped:(id)sender event:(id)event
{
    CGPoint touchPosition = [[[event allTouches] anyObject] locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPosition];
    if (indexPath != nil) {
        NSDictionary *audioDict = self.audios[indexPath.row];
        NSURL *audioURL = [NSURL URLWithString:[audioDict objectForKey:@"url"]];
        [GNNhkAccessManager downloadAndDecryptAudios:audioURL];
    }
}

@end
