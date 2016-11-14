//
//  NSStack.h
//  demo2
//
//  Created by sigbit on 16/1/5.
//  Copyright © 2016年 sigbit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStack : NSObject

@property (nonatomic, strong) NSMutableArray *stackArray;

- (BOOL) empty;

- (id) top;

- (void) pop;

- (void) push:(id)value;

@end
