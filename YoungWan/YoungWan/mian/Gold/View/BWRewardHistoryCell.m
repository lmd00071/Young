//
//  BWRewardHistoryCell.m
//  WidomStudy
//
//  Created by Sigbit on 16/4/15.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import "BWRewardHistoryCell.h"

#import "BWRewardHistory.h"

#import <UIImageView+WebCache.h>

@interface BWRewardHistoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation BWRewardHistoryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setRewardHistory:(BWRewardHistory *)rewardHistory
{
    _rewardHistory = rewardHistory;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:rewardHistory.icon]];
    self.mainTitleLabel.text = rewardHistory.title;
    self.subTitleLabel.text = rewardHistory.sub_title;
}

@end
