//
//  NSStringToBetyArray.h
//  YoungWan
//
//  Created by 李明丹 on 16/4/21.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <string.h>
#define TABLE_SIZE  35023L
#define TABLE_BANKS  ((TABLE_SIZE >> 8) + 1)
typedef unsigned short int WORD;
typedef unsigned char BYTE;
typedef unsigned long DWORD;

//const int UNUSED = -1;
//const int FIRST_CODE = 259;

//const int BITS = 15;
//const int MAX_CODE = ((1 << BITS) - 1);
//const int END_OF_STREAM = 256;
//const int BUMP_CODE = 257;
//const int FLUSH_CODE = 258;
#pragma pack(4)
typedef struct bit_file
{
    int buffer_position;
    int rack;
    unsigned char mask;
    char buffer[1024*1024];
    int buffer_length;
    int pacifier_counter;
} BIT_FILE;
#pragma pack()
@interface NSStringToBetyArray : NSObject

@property (nonatomic,assign)WORD next_code;
@property (nonatomic,assign)int current_code_bits;
@property (nonatomic,assign)WORD next_bump_code;

@property (nonatomic,assign)int number;
-(NSData *)encryptString:(NSString *)str;

@end
