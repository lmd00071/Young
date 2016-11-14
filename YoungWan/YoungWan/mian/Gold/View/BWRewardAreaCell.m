//
//  BWRewardAreaCell.m
//  WidomStudy
//
//  Created by Sigbit on 16/4/19.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import "BWRewardAreaCell.h"

#import "BWRewardArea.h"

#import <UIImageView+WebCache.h>

@interface BWRewardAreaCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goldLabel;

@end

@implementation BWRewardAreaCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRewardArea:(BWRewardArea *)rewardArea
{
    _rewardArea = rewardArea;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:rewardArea.icon]];
    self.nameLabel.text = rewardArea.product;
    self.goldLabel.text = rewardArea.yp;
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.x += BWSmallMargin;
    frame.origin.y += BWMargin;
    frame.size.width -= BWMargin;
    [super setFrame:frame];
}

@end
