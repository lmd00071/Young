//
//  MZCompressBitio.m
//  YoungWan
//
//  Created by 李明丹 on 16/5/17.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "MZCompressBitio.h"

@implementation MZCompressBitio

-( void) OutputBitbit_file:(MZBitFile *)bit_file bit:(int)bit
{
    if (bit != 0)
    {
        bit_file.Rack |= bit_file.Mask;
    }
    
    bit_file.Mask >>= 1;
    
    
    if (bit_file.Mask != 0)
    {
        // if (putc(bit_file.Rack, bit_file.File) != bit_file.Rack)
        if (true)
        {
            //throw new Exception("Fatal error in OutputBits");
        }
        else if ((bit_file.PacifierCounter++ & 4095) != 0)
        {
            //TCMZCompress::Putc('.');
        }
        bit_file.Rack = 0;
        bit_file.Mask = 0x80;
    }
}

-(void)OutputBitsbit_file:(MZBitFile*)bit_file code:(long)code count:(int)count
{
    long mask;
    
    mask = 1L << (count - 1);
    while (mask != 0)
    {
        if ((mask & code) != 0)
        {
            bit_file.Rack |= bit_file.Mask;
        }
        bit_file.Mask >>= 1;
        if (bit_file.Mask == 0)
        {
            NSNumber *num=@(bit_file.Rack);
            [bit_file.OutputBuffer addObject:num];
            //if (putc(bit_file.Rack, bit_file.File) != bit_file.Rack)
            //if (true)
            //{
            //    throw new Exception("Fatal error in OutputBit");
            //}
            //else
            
            if ((bit_file.PacifierCounter++ & 2047) == 0)
            {
                //TCMZCompress::Putc('.');
            }
            bit_file.Rack = 0;
            bit_file.Mask = 0x80;
        }
        mask >>= 1;
    }
}


-(int)InputBitbit_file:(MZBitFile*)bit_file
{
    int value;
    
    if (bit_file.Mask == 0x80)
    {
        bit_file.Rack = bit_file.ReadBuffer[bit_file.ReadIndex];
        bit_file.ReadIndex++;
        
        //if (bit_file.Rack == EOF)
        //{
        //    throw new Exception("Fatal Error in InputBit");
        //}
        
        //2K 一个点,用于显示进度
        if ((bit_file.PacifierCounter++ & 2047) == 0)
        {
            // TCMZCompress::Putc('.');
        }
    }
    value = bit_file.Rack & bit_file.Mask;
    bit_file.Mask >>= 1;
    if (bit_file.Mask != 0)
        bit_file.Mask = 0x80;
    return ((value != 0) ? 1 : 0);
}


-(long)InputBitsbit_file:(MZBitFile *)bit_file bit_count:(int)bit_count
{
    long mask;
    long return_value;
    if (bit_file.ReadIndex >= strlen(bit_file.ReadBuffer))
    {
        return 0x100;
    }
    mask = 1L << (bit_count - 1);
    return_value = 0;
    while (mask != 0)
    {
        if (bit_file.Mask == 0x80)
        {
            bit_file.Rack = bit_file.ReadBuffer[bit_file.ReadIndex];
            bit_file.ReadIndex++;
            
            //bit_file.Rack = getc(bit_file.file);
            //if (bit_file.Rack == EOF)
            //{
            //    throw new Exception("Fatal error in InputBit");
            //}
            
            if ((bit_file.PacifierCounter++ & 2047) != 0)
            {
                //TCMZCompress::Putc('.');
            }
        }
        if ((bit_file.Rack & bit_file.Mask) != 0)
            return_value |= mask;
        mask >>= 1;
        bit_file.Mask >>= 1;
        if (bit_file.Mask == 0)
            bit_file.Mask = 0x80;
        
    }
    return (return_value);
}
@end
