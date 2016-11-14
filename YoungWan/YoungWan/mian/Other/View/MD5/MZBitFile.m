//
//  MZBitFile.m
//  YoungWan
//
//  Created by 李明丹 on 16/5/17.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "MZBitFile.h"

@implementation MZBitFile

//+ (instancetype)shareManager
//{
//    static MZBitFile *manager=nil;
//    if (!manager) {
//        
//        static dispatch_once_t oneToken;
//        dispatch_once(&oneToken, ^{
//            
//            manager=[[MZBitFile alloc]init];
//        });
//    }
//    return manager;
//}

- (instancetype)init
{
    self.ReadBuffer=NULL;
    self.OutputBuffer=[NSMutableArray array];
    self.ReadIndex=0;
    self.Mask=0x80;
    self.Rack=0;
    self.PacifierCounter=0;
    return self;
}
- (void)AddByte:(NSData *)b
{
    [_OutputBuffer addObject:b];

}

@end
