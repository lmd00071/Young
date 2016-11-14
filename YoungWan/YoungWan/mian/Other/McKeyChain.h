//
//  McKeyChain.h
//  Drive
//
//  Created by 朱健 on 16/5/25.
//  Copyright © 2016年 Macro. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "McKeyChainConstant.h"

@interface McKeyChain : NSObject

// 存入数据到keychain
+ (void)save:(NSString*)service data:(id)data;

// 获取数据
+ (id)load:(NSString*)service;

// 删除数据
+ (void)delete:(NSString*)service;

@end
