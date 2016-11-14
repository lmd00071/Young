//
//  GoldTableViewController.h
//  SeaSwallowClassRoom
//
//  Created by 李明丹 on 16/6/13.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WIFImodel.h"
@interface GoldTableViewController : UITableViewController

@property (nonatomic,strong)WIFImodel *model;
@property(nonatomic,copy)void(^Getblock)(NSString *);

@end
