//
//  BWCSVModel.h
//  WidomStudy
//
//  Created by Sigbit on 16/1/27.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWCSVModel : NSObject

//csv文件的类型
@property (nonatomic, copy) NSString *csvType;

//csv文件的地址
@property (nonatomic, copy) NSString *csvPath;

//过期时间
@property (nonatomic, copy) NSString *overdueTime;

//用来区分页目csv的参数1
@property (nonatomic, copy) NSString *action;

//用来区分页目csv的参数2
@property (nonatomic, copy) NSString *action_parameter;


@end
