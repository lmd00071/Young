//
//  alipayTableViewCell.m
//  YoungWan
//
//  Created by 李明丹 on 16/8/29.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "alipayTableViewCell.h"
#import "UIImageView+WebCache.h"
@interface alipayTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *payImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLable;
@property (strong, nonatomic) IBOutlet UILabel *styleLabel;
@property (strong, nonatomic) IBOutlet UILabel *payMoneyLable;

@end

@implementation alipayTableViewCell



- (void)getmodel:(alipayModel *)model
{
    [self.payImageView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@""]];
    self.titleLable.text=model.product_name;
    self.styleLabel.text=model.recharge_type_text;
    self.payMoneyLable.text=model.show_fee_text;
    self.payImageView.image=[UIImage imageNamed:@"aipay"];

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
