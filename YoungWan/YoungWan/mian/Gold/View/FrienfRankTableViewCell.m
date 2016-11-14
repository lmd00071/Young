//
//  FrienfRankTableViewCell.m
//  YoungWan
//
//  Created by 李明丹 on 16/10/8.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "FrienfRankTableViewCell.h"
#import "UIImageView+WebCache.h"
@interface FrienfRankTableViewCell ()
//冠军
@property (strong, nonatomic) IBOutlet UIImageView *cupImageView;
//人物头像
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
//姓名
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
//电话
@property (strong, nonatomic) IBOutlet UILabel *phoneNumberLabel;
//金币
@property (strong, nonatomic) IBOutlet UILabel *goldLabel;
//金币图案
@property (strong, nonatomic) IBOutlet UIImageView *moneyImageView;

@end

@implementation FrienfRankTableViewCell


- (void)getmodel:(firendRankMmodel *)model
{
    if (self.Isone) {
        
        self.cupImageView.image=[UIImage imageNamed:@"cup1"];
        
    }else{
        
        if ([model.rank_pos isEqualToString:@"1"]) {
            self.cupImageView.image=[UIImage imageNamed:@"cup1"];
        }
        if ([model.rank_pos isEqualToString:@"2"]) {
            self.cupImageView.image=[UIImage imageNamed:@"cup2"];
        }
        if ([model.rank_pos isEqualToString:@"3"]) {
            self.cupImageView.image=[UIImage imageNamed:@"cup3"];
        }
    }
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.head_icon] placeholderImage:[UIImage imageNamed:@"setting_default_head-1"]];
    self.nameLabel.text=@"我";
    self.phoneNumberLabel.text=model.msisdn;
    self.goldLabel.text=model.yp_value;
    self.moneyImageView.image=[UIImage imageNamed:@"friend_ranking_gold"];
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
