//
//  FrienfRankTableViewCell.h
//  YoungWan
//
//  Created by 李明丹 on 16/10/8.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "firendRankMmodel.h"
@interface FrienfRankTableViewCell : UITableViewCell

- (void)getmodel:(firendRankMmodel *)model;

@property (nonatomic,assign)BOOL Isone;

@end
