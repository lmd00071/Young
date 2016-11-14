//
//  friendAttModel.m
//  YoungWan
//
//  Created by 李明丹 on 16/10/8.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "friendAttModel.h"

@implementation friendAttModel
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
    
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    
    if ([key isEqualToString:@"标题"]) {
        
        [self setValue:value forKey:@"title"];
    }
    
    if ([key isEqualToString:@"广告图"]) {
        
        [self setValue:value forKey:@"advertisement"];
        
    }
    
    if ([key isEqualToString:@"邀请提示"]) {
        
        [self setValue:value forKey:@"Messager"];
        
    }
    
}

@end
