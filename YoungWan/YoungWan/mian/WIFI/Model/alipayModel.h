//
//  alipayModel.h
//  YoungWan
//
//  Created by 李明丹 on 16/8/29.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface alipayModel : NSObject

@property (nonatomic,strong)NSString *group;
@property (nonatomic,strong)NSString *icon;
@property (nonatomic,strong)NSString *product_id;
@property (nonatomic,strong)NSString *product_name;
@property (nonatomic,strong)NSString *product_desc;
@property (nonatomic,strong)NSString *recharge_fee;
@property (nonatomic,strong)NSString *show_fee_text;
@property (nonatomic,strong)NSString *recharge_type;
@property (nonatomic,strong)NSString *recharge_type_text;
@property (nonatomic,strong)NSString *recharge_time;

@end
