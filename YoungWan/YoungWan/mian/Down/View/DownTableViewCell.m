//
//  DownTableViewCell.m
//  YoungWan
//
//  Created by 李明丹 on 16/9/22.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "DownTableViewCell.h"
#import "UIImageView+WebCache.h"
@interface DownTableViewCell()

@property (strong, nonatomic) IBOutlet UIImageView *titleImageView;

@property (strong, nonatomic) IBOutlet UILabel *nameLable;

@property (strong, nonatomic) IBOutlet UILabel *downloadLabel;
@property (strong, nonatomic) IBOutlet UILabel *rewardLabel;

@end

@implementation DownTableViewCell


- (void)getmodel:(DownDodel *)model
{
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:model.app_icon] placeholderImage:[UIImage imageNamed:@""]];
    self.nameLable.text=model.app_name;
    self.downloadLabel.text=model.downloaded_tips;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"赚%@金币",model.reward_yp]];
     NSRange contentRange = {1,2};
    [str addAttribute:NSForegroundColorAttributeName value:HBRGBColor(211, 150, 95, 1) range:contentRange];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:nil size:26] range:contentRange];
    self.rewardLabel.attributedText = str;

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
