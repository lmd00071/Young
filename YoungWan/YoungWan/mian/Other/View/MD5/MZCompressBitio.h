//
//  MZCompressBitio.h
//  YoungWan
//
//  Created by 李明丹 on 16/5/17.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZBitFile.h"

@interface MZCompressBitio : NSObject
-( void) OutputBitbit_file:(MZBitFile *)bit_file bit:(int)bit;
-(void)OutputBitsbit_file:(MZBitFile*)bit_file code:(long)code count:(int)count;
-(int)InputBitbit_file:(MZBitFile*)bit_file;
-(long)InputBitsbit_file:(MZBitFile *)bit_file bit_count:(int)bit_count;
@end
