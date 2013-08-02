//
//  GNAudioCell.h
//  GogakuForNHK
//
//  Created by Maezono Yusaku on 2013/07/30.
//  Copyright (c) 2013年 crossgate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GNAudioCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *dateLable;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *downloadButton;

@end
