//
//  MZBitFile.h
//  YoungWan
//
//  Created by 李明丹 on 16/5/17.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZBitFile : NSObject
//{
//    @public
//     Byte *_ReadBuffer;
//     NSMutableArray * _OutputBuffer;
//     int _ReadIndex;
//     Byte  _Mask;
//     int _Rack;
//     int _PacifierCounter;
//}

@property(nonatomic,assign)Byte *ReadBuffer;
@property(nonatomic,strong)NSMutableArray * OutputBuffer;
@property(nonatomic,assign)int ReadIndex;
@property(nonatomic,assign)Byte  Mask;
@property(nonatomic,assign)int Rack;
@property(nonatomic,assign)int PacifierCounter;


- (instancetype)init;
- (void)AddByte:(Byte)b;
@end
